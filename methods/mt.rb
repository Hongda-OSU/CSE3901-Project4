require 'mechanize'
require 'nokogiri'

agent = Mechanize.new
page = agent.get "https://web.cse.ohio-state.edu/~davis.1719/publications.html"

def info page
    samples = page.xpath('//li')
    samples.each_with_index { |sample, index| puts sample.to_s if index < 1 }
end

def get_sample page
  samples = page.xpath('//li')
  name = "J. Davis"

  # these are the source that don't have a pattern
  weird_source = ["arXiv:2007.01386v1 [cs.LG], July 2020.",
                  "Commericialization of audio algorithm and software for multi-channel audio polarity optimization, 2015.",
                  "OSU Dept. Computer Science and Engineering Technical Report OSU-CISRC-11/11-TR34, 2011.",
                  "OSU Dept. Computer Science and Engineering Technical Report OSU-CISRC-6/10-TR13, 2010.",
                  "OSU Dept. Computer and Information Science Technical Report OSU-CISRC-11/00-TR25, November 2000.",
                  "MIT Technical Report #487, March 1999."]

  samples.each do |sample|
    publication = sample.to_s
    len = publication.length

    #get the publication title
    title = String.new
    m_title = publication.match /".*"|“.*”/
    title = m_title.to_s.slice(1, m_title.to_s.length-2)

    # get the publication author, if not exist, use None
    author = String.new
    if publication.include? name
      fb_index = publication.index "<br>"
      sb_index = publication[fb_index+5...len].index "<br>" #get the first char index of <b>, beware <b>\n
      author = publication[fb_index+5... fb_index+sb_index+5] #get the second char index of <b> from the remaining string
      author.lstrip! #clear the possible \n when encounter some weird html code
      if publication.include? "P. Hart" # deal with special case in publication number 4
        tb_index = publication[fb_index+sb_index+10...len].index "<br>"
        special = publication[fb_index+sb_index+10...fb_index+sb_index+10+tb_index]
        author.concat " ", special
      end
    else
      author = "None"
    end

    # get the publication source, weird_source is seperated
    source = String.new
    if publication.include? "<i>"
      fi_index = publication.index "<i>" # get the char index of <i>
      si_index = publication[fi_index+3...len].index "</i>" # get the char index of </i>
      source = publication[fi_index+3...fi_index+3+si_index] # get the source, without date
      stb_index = publication[fi_index+7+si_index...len].index "<br>" # get the char index of <br> to find date
      date = publication[fi_index+7+si_index...fi_index+7+si_index+stb_index] #get date
      date.lstrip!
      source.concat date
    else
      source = weird_source.shift # get source from the weird source array
    end

    # get link from the publication page, note there are PDF, HTML and a weird Audiomere link
    link = String.new
    if publication.include? "href="
      h_index = publication.index "href="
      end_index = publication[h_index+6...len].index ">"
      link = publication[h_index+6...h_index+6+end_index-1]
    else
      link = "None"
    end
    puts link

  end

end



#info page
get_sample page
