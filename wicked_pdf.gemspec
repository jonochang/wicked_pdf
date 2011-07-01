Gem::Specification.new do |s|
  s.name              = "wicked_pdf"
  s.version           = "0.6.9"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "PDF generator (from HTML) plugin for Ruby on Rails"
  s.homepage          = "http://github.com/jonochang/wicked_pdf"
  s.email             = "jonathan.chang@silverpond.com.au"
  s.authors           = [ "Miles Z. Sterret", "Jonathan Chang" ]

  s.files             = %w( README.md Rakefile MIT-LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.description       = <<desc
Wicked PDF uses the shell utility wkhtmltopdf to serve a PDF file to a user from HTML.
In other words, rather than dealing with a PDF generation DSL of some sort,
you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.
desc
end
