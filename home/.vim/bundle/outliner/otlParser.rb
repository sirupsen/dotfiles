#!/usr/bin/env ruby
# Module for parsing/formatting TVO outlines.
# $Id: otlParser.rb 118 2006-04-17 21:12:45Z ned $

require 'stringio'
require 'getoptlong'

module TVO

  RETodo1      = /\b(TODO|XXX|NOTE)\b/
  REStandout   = /\*\*\s*\b(.+?)\b\s*\*\*/

  RETagDef     = /<id=([^>]+)>|\[\[([^\[\]]+)\]\]/i
  REExternTagRef     = /<url:\s*([^>]+)\s*>|\[([a-z]+:[^\]]+)\]/i
  RETagRef     = /\[([^\[\]:]+)\]/
  REVimTagRef  = /\[(:[^\[\]:]+)\]/
  REHTMLOnly   = /(.*?)\s*<html:\s*([^>]+|<[^>]+>)\s*>\s*(.*)/i

  REItalic    = /I<(.+?)>/
  REBold      = /B<(.+?)>/
  RECode      = /C<(.+?)>/
  REUnderline = /U<(.+?)>/

  RETextLeader = /^\t*\|\s*/
  REText       = /^\t*\|\s*(.*)/

  # outlineItem := head text? outlineItem*
  # 
  # from Vim syntax definition:
  # text
  #   contains=vikiHyperLinks,RETodo,RETagDef,RETagRef,RETextLeader nextgroup=REText 
  # RETabs : /^\t\{0-9}[^\t|].*/
  #   contains=vikiHyperLinks,RETodo,RETagDef,RETagRef nextgroup=RETabs,REText 
  # vikiHyperLinks = vikiLink,vikiExtendedLink,vikiURL,vikiInexistentLink 
  # 
  class Item
  public

    attr_accessor :parent, :keepHead
    attr_reader :head, :children, :level

    def initialize(level, head='', text=nil, parent=nil, children=[])
      @level = level 
      @head = head
      @text = text ? text.to_a.join("\n").split("\n") : []
      @children = children
      @parent = parent
      @keepHead = false
      self
    end

    def head=(headText)
      if headText.nil?
        @head = headText
      elsif headText[0..0] == '+'
        @keepHead = true
        @head = headText[1..-1]
      else
        @head = headText
      end
    end

    def addText(text)
      @text.push(text)
    end

    def addChild(child)
      @children.push(child)
      child.parent = self
    end

    def children=(_children)
      _children.each { |c| addChild(c) }
    end

    def text
      @text
    end

    def text=(_text)
      @text = _text.split("\n")
    end

    def each_text_line(&blk)
      text.each(&blk)
    end

    # returns array of arrays [marker, para]
    # marker is '' or '-' or '*'
    # para is array of paragraph lines 
    def textParagraphs
      paras = []
      thisPara = []
      markerLength = 0
      marker = ''
      text.each do |textline|
        case textline
        when /^(\s*([-*])\s*)(.*)/ 
          paras.push([ marker, thisPara ])
          marker = $2
          markerLength = $1.length
          thisPara = [ $3 ]
        when /^(\s*)(.+)/
          if $1.length == markerLength
            thisPara.push($2)
          else
            paras.push([ marker, thisPara ])
            markerLength = $1.length
            thisPara = [ $2 ]
            marker = ''
          end
        when /^\s*$/
          paras.push([ marker, thisPara ])
          thisPara = []
          marker = ''
        end
      end
      paras.push([ marker, thisPara ])
      return paras.reject { |p| p[1].length == 0 }
    end

    # calls given block with:
    #   array of related lines
    #   marker ('' or '-' or '*')
    def relatedTextParagraphsDo
      lastMarker = ''
      related = []
      paras = textParagraphs
      paras.push([nil, []])  # to flush last one
      paras.each do |p|
        marker = p[0]
        textLines = p[1]
        if marker == lastMarker
          related.push(textLines)
        else
          # process related paragraphs if any
          if related.length > 0
            yield related, lastMarker
          end
          lastMarker = marker
          related = [ textLines ]
        end
      end
    end

  end

  class Formatter
  protected

    # default output is just flattened.
    def printHead?(item)
      return (!@textOnly || item.keepHead)
    end

    def visitHead(item,seq=0)
      return unless printHead?(item)
      file().puts(embellish(item.head), "")
    end

    def visitText(item,seq=0)
      item.text.each { |textLine| file.puts(embellish(textLine)) }
      file.puts("") if item.text.length > 0
    end

    def visitItem(item,seq=0)
      if item.level >= 0
        visitHead(item,seq)
        visitText(item,seq)
      end
      item.children.each_with_index { |ch,n| visitItem(ch,n) }
      nil
    end

    # format individual spans

    def italic(text) ; text; end
    def bold(text) ; text; end
    def code(text) ; text; end
    def underline(text) ; text; end
    def standout(text) ; text; end
    def tagDef(text) ; text; end
    def tagRef(text) ; text; end
    def vimTagRef(text) ; text; end
    def htmlOnly(text); end

    def embellish(text)
      text.
        gsub(REItalic)    { |s| italic($1) }.
        gsub(REBold)      { |s| bold($1) }.
        gsub(RECode)      { |s| code($1) }.
        gsub(REUnderline) { |s| underline($1) }.
        gsub(REStandout)  { |s| standout($1) }.
        gsub(RETagDef)    { |s| tagDef($1||$2) }.
        gsub(RETagRef)    { |s| tagRef($1) }.
        gsub(REVimTagRef) { |s| vimTagRef($1) }.
        gsub(REHTMLOnly)  { |s| htmlOnly($1) }
    end

  public

    def self.formatterNames
      TVO.constants.
        select { |c|
          cl = TVO.const_get(c) rescue ''
          cl.kind_of?(Class) && cl <= self
         }.collect { |cn| cn.sub(/Formatter$/, '') }.
         sort
    end

    attr_accessor :file, :textOnly

    def initialize(_file=$stdout)
      @file = _file
      @textOnly = false
    end

    def format(outlineRoot)
      visitItem(outlineRoot)
    end
  end

  # Output TVO again (for building OTL files programmatically)
  class OutlineFormatter < Formatter
  protected
    Prefixes = (0..9).to_a.collect { |n| ("\t" * n) }

    def prefixForLevel(level)
      Prefixes[level] || ((level < 0) ? "" : ("\t" * level))
    end

    def visitHead(item,seq=0)
      return unless printHead?(item)
      file.print(prefixForLevel(item.level), item.head, "\n")
    end

    def visitText(item,seq=0)
      prefix = prefixForLevel(item.level) + '| '
      item.text.each { |tline| file.print(prefix, tline, "\n") }
    end

  end

  # Format outline as h1-h6/ul
  # Classes used are:
  # <a href="">
  #   otlExternTagRef
  #   otlTagRef
  # <a name="">
  #   otlTagDef
  # <span>
  #   otlHTMLOnly
  #   otlTodo
  #   otlStandout
  #   otlVimTagRef
  #   otlUnderline
  # <hr>
  #   h1 .. h<#>
  # <h1> .. <h5>
  #   h1 .. h6
  # <h6>
  #   h6 .. h<#>
  # <ul>,<li>
  #   t<#>pd  (if marker was '-')
  #   t<#>pa  (if marker was '*')
  # <div>,<p>
  #   t<#>p
  #
  #
  class HTMLFormatter < Formatter

  def self.quoted(text)
    text.gsub(/&/, '&amp;').  gsub(/</, '&lt;').  gsub(/>/, '&gt;')
  end

  def self.requoted(re)
    Regexp.new(re.source.gsub(/\\\\/, '\\'). gsub(/</, '&lt;').  gsub(/>/, '&gt;'))
  end

  RETagDef     = /&lt;id=([^&]+)&gt;|\[\[([^\[\]]+)\]\]/i
  REExternTagRef     = /&lt;url:\s*([^>]+)\s*&gt;|\[([a-z]+:[^\]]+)\]/i
  RETagRef     = /\[([^\[\]:&]+)\]/
  REVimTagRef  = /\[(:[^\[\]:&]+)\]/
  REHTMLOnly   = /(.*?)\s*&lt;html:\s*(.+?|.*&lt;.+?&gt;)\s*&gt;\s*(.*)/i

  REItalic    = /I&lt;(.+?)&gt;/
  REBold      = /B&lt;(.+?)&gt;/
  RECode      = /C&lt;(.+?)&gt;/
  REUnderline = /U&lt;(.+?)&gt;/
  REGtLt      = /&&([gl]t;)/

  protected
    # notice in-text markings
    # Would be run after quoted
    def decorated(textLine)
      if textLine.match(REHTMLOnly)
        return textLine.
          gsub(REHTMLOnly) do |s|
            "#{decorated($1)} <span class=\"otlHTMLOnly\">#{$2}</span> #{decorated($3)}"
          end
      else
        return textLine.
          gsub(REGtLt)  {|s| "&#{$1}" }.
          gsub(REItalic)  {|s| "<i>#{$1}</i>" }.
          gsub(REBold)  {|s| "<strong>#{$1}</strong>" }.
          gsub(RECode)  {|s| "<tt>#{$1}</tt>" }.
          gsub(REUnderline)  {|s| "<span class=\"otlUnderline\">#{$1}</span>" }.
          gsub(RETodo1)   {|s| "<span class=\"otlTodo\">#{s}</span>" }.
          gsub(REStandout)   {|s| "<span class=\"otlStandout\">#{$1}</span>" }.
          gsub(RETagDef)  {|s| "<a class=\"otlTagDef\" name=\"#{urlEncoded($1||$2)}\"></a>" }.
        gsub(REExternTagRef){|s|
          "<a class=\"otlExternTagRef\" href=\"#{urlEncoded($1||$2)}\">#{$1||$2}</a>" }.
        gsub(RETagRef)  do |s|
          url=dest=$1
          if dest =~ /^--\s*(.+)\s*--$/
            url = dest = $1
          end
          if dest =~ /^([^#]+)#([^#]+)$/
            url=dest
            dest=$1
          end
          if File.readable?(dest)
            "<a class=\"otlExternTagRef\" href=\"#{urlEncoded(url)}\">#{url}</a>"
          else
            "<a class=\"otlTagRef\" href=\"##{urlEncoded(url)}\">#{url}</a>"
          end
        end.
        gsub(REVimTagRef) { "<span class=\"otlVimTagRef\">#{$&}</span>" }
      end
    end

    def quoted(text)
      self.class.quoted(text).gsub(/\n/, "\n" + (" " * @nest))
    end

    def urlEncoded(text)
      text.gsub(/[^#.A-Za-z0-9]/) { |c| sprintf("%%%02X", c[0]) }
    end

    def htmlTag(tagname, attribs={})
      file.print("\n", " " * @nest)
      file.print('<', tagname)
      attribs.each_pair { |k,v| file.print(" #{k}=\"#{quoted(v)}\"") }
      if block_given?
        file.print('>')
        @nest += 1
        text = yield
        @nest -= 1
        file.print(decorated(quoted(text))) if text
        file.print('</', tagname, '>')
      else
        file.print(' />')
      end
      nil
    end

    def tagAndClassForHead(itemLevel)
      hLevel = "h#{itemLevel}"
      tag = (itemLevel.between?(1,6) ? hLevel : 'h6')
      return *[tag, hLevel]
    end

    def visitHead(item,seq=0)
      return unless printHead?(item)
      itemLevel = item.level + 1
      (tag, hLevel) = tagAndClassForHead(itemLevel)
      if itemLevel == 1 && seq > 0
        htmlTag('hr', { :class => hLevel })
      end
      htmlTag(tag, { :class => hLevel } ) { item.head }
    end

    def tagsAndClassForTextPara(itemLevel,marker)
      case marker
      when '-'
        return *['ul','li',"t#{itemLevel}pd"]
      when '*'
        return *['ul','li',"t#{itemLevel}pa"]
      else
        return *['div','p',"t#{itemLevel}p"]
      end
    end

    def formatTextParagraph(para, itemTag, itemClass)
      htmlTag(itemTag, {:class => itemClass }) { para.join("\n") }
    end

    def visitText(item,seq=0)
      item.relatedTextParagraphsDo do |related, marker|
        (groupTag,itemTag,itemClass) = tagsAndClassForTextPara(item.level,marker)
        htmlTag(groupTag, {:class => itemClass }) do
          related.each { |p| formatTextParagraph(p, itemTag, itemClass) }
              nil
          end
        end
    end

  public
    attr_accessor :stylesheet

    def self.defaultStylesheet
      "tvo.css"
    end

    def initialize(_file=$stdout)
      super
      @nest = 0
      @stylesheet = self.class.defaultStylesheet
    end

    def format(outlineRoot)
      file.print('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">')
      htmlTag('html') do
        htmlTag('head') do
          htmlTag('title') { outlineRoot.children[0].head }
          htmlTag('link', { :rel => 'stylesheet', :type => 'text/css', :href => stylesheet() })
        end
        htmlTag('body') { visitItem(outlineRoot) }
      end
    end

  end

  # Format entire outline as nested series of ul/li/ul
  class HTMLListFormatter < HTMLFormatter

    def visitHead(item,seq=0)
      return unless printHead?(item)
      hLevel = "h#{item.level + 1}"
      htmlTag('li', { :class => hLevel } ) { item.head }
    end

    def visitItem(item, seq=0)
      hLevel = "h#{item.level + 1}"
      if item.level >= 0
        if item.level == 0 && seq > 0
          htmlTag('hr', { :class => hLevel })
        end
        visitHead(item,seq)
        visitText(item,seq)
      end
      if item.children.length > 0
        htmlTag('ul', { :class => hLevel }) do
          item.children.each_with_index { |ch,n| visitItem(ch,n) }
          nil
        end
      end
    end
  end

  # Construct an OutlineItem (the root item) from input text.
  class Parser
  protected
    @@debug = false

    def gets(sepString = $/)
      retval = @getback.gets(sepString) || @file.gets(sepString)
      if retval.nil?
        $stderr.puts("(EOF)") if @@debug
        throw(:eof, nil) 
      end
      return retval.chomp(sepString)
    end

    def puts(line)
      @pushback.puts(line)
      @pushback.sync
    end

    def head(level)
      $stderr.print("Looking for head(#{level})") if @@debug
      line = gets
      if m = line.match(@tabREs[level]) and m[2][0..0] != '|'
        $stderr.print("... got #{m[2]}\n") if @@debug
        return m[2]
      else
        puts(line)
        $stderr.print("... rej #{line.inspect}\n") if @@debug
        return nil
      end
    end

    def text(level)
      $stderr.print("Looking for text(#{level})") if @@debug
      line = gets
      if m = line.match(@tabREs[level]) and m[2].match(/\|\s?(.*)/)
        $stderr.print("... got #{m[2][2..-1]}\n") if @@debug
        return $1
      else
        puts(line)
        $stderr.print("... rej #{line.inspect}\n") if @@debug
        return nil
      end
    end

    # get next outline item that starts with (at least) "level" tabs.
    # return single item.
    def item(level)
      throw(:toodeep, nil) if level > 9
      catch(:eof) do
        catch(:toodeep) do
          retval = Item.new(level)
          retval.head = head(level)
          return nil unless retval.head
          catch(:eof) do
            while t = text(level)
              retval.addText(t)
            end
          end
          retval.children = items(level+1)
          $stderr.puts("Returning item [level=#{level}] [head=\"#{retval.head}\"] [text=#{retval.text.length}lns]") if @@debug
          retval
        end
      end
    end

    # return array of items at the given level.
    def items(level)
      retval = []
      while nextItem = item(level)
        retval.push(nextItem)
      end
      return retval
    end

  public

    def initialize(file=$stdin)
      @pbString = ""
      @pushback = StringIO.new(@pbString)
      @getback = StringIO.new(@pbString)
      @file=file
      @tabREs = (0..9).to_a.collect { |n| Regexp.new("^(\\t{#{n}})(\\S.*)") } 
    end

    def outline
      return Item.new(-1, '', nil, nil, items(0))
    end

    def Parser.debugMode=(bool)
      @@debug = bool
    end

  end # class Parser

  # read options from ARGV
  def parseAndFormat

    # parse arguments
    formatType = ''
    outputFileName = nil
    textOnly = false

    parser = GetoptLong.new
    parser.set_options(
      [ '--format', '-f', GetoptLong::REQUIRED_ARGUMENT],
      [ '--help', '-h', GetoptLong::NO_ARGUMENT],
      [ '--output', '-o', GetoptLong::REQUIRED_ARGUMENT],
      [ '--debug', '-d', GetoptLong::NO_ARGUMENT],
      [ '--stylesheet', '-s', GetoptLong::REQUIRED_ARGUMENT],
      [ '--include', '-i', GetoptLong::REQUIRED_ARGUMENT],
      [ '--textonly', '-t', GetoptLong::NO_ARGUMENT])
    parser.each_option do |name, arg|
      case name
      when '--format'
        formatType = arg
      when '--help'
        $stderr.print <<-EOF
          Usage: #{$0} [opt] [file [...]]
          opt is one or more of:
            --format, -f #{ "<'" + Formatter.formatterNames().join("'|'") + "'>" }  set output format type
            --help, -h                            display this help
            --output, -o <filename>               output to file named filename instead of stdout
            --debug, -d                           turn on parser debugging to stderr
            --textonly, -t                        omit heads except those starting with '+'
            --stylesheet, -s <filename>           link to stylesheet named filename (default=#{HTMLFormatter.defaultStylesheet})
            --include, -i <filename>              include Ruby module filename
EOF
        exit(0)
      when '--output'
        outputFileName = arg
      when '--debug'
        Parser.debugMode = true
      when '--textonly'
        textOnly = true
      when '--include'
        require arg
      end
    end

    outputFile = outputFileName.nil? ? $stdout : File.open(outputFileName, 'w')
    outline = Parser.new(ARGF).outline
    formatterClass = TVO.const_get("#{formatType}Formatter")
    formatter = formatterClass.new(outputFile)

    formatter.textOnly = textOnly
    formatter.format(outline)

  end

end # module TVO

if $0 == __FILE__
  include TVO
  parseAndFormat
end
