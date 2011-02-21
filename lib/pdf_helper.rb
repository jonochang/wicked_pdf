module PdfHelper
  require 'wicked_pdf'
  require 'wicked_pdf_tempfile'

  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :wicked_pdf
    end
  end

  def render_with_wicked_pdf(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      logger.info '*'*15 + 'WICKED' + '*'*15
      make_and_send_pdf(options.delete(:pdf), (WickedPdf.config || {}).merge(options))
    else
      render_without_wicked_pdf(options, *args, &block)
    end
  end

  def save_wicked_pdf_to(options = {})
    options[:wkhtmltopdf] ||= nil
    options[:layout] ||= false
    options[:template] ||= File.join(controller_path, action_name)
    options[:disposition] ||= "inline"

    options = prerender_header_and_footer(options)
    pdf_content = make_pdf(options)

    save_file_path = options[:save_to_file] #File.join(save_folder_path, "#{rand}.pdf")
    File.open(save_file_path, 'wb') {|file| file << pdf_content } 
  end

  private
    def make_pdf(options = {})
      html_string = externals_to_absolute_path(render_to_string(:template => options[:template], :layout => options[:layout]))
      w = WickedPdf.new(options[:wkhtmltopdf])
      w.pdf_from_string(html_string, options)
    end

    def make_and_send_pdf(pdf_name, options = {})
      options[:wkhtmltopdf] ||= nil
      options[:layout] ||= false
      options[:template] ||= File.join(controller_path, action_name)
      options[:disposition] ||= "inline"

      options = prerender_header_and_footer(options)
      if options[:show_as_html]
        render :template => options[:template], :layout => options[:layout], :content_type => "text/html"
      else
        pdf_content = make_pdf(options)
        File.open(options[:save_to_file], 'wb') {|file| file << pdf_content } if options[:save_to_file]
        send_data(pdf_content, :filename => pdf_name + '.pdf', :type => 'application/pdf', :disposition => options[:disposition]) unless options[:save_only]
      end
    end

    # Given an options hash, prerenders content for the header and footer sections
    # to temp files and return a new options hash including the URLs to these files.
    def prerender_header_and_footer(options)
      files_to_delete = []
      [:header, :footer].each do |hf|
        if options[hf] && options[hf][:html] && options[hf][:html][:template]
          File.open("/tmp/wicked_pdf_hf_#{rand}.html", "w") do |f|
            
            options_for_render = {
              :template => options[hf][:html][:template],
              :layout => options[:layout]
            }

            options_for_render[:layout] = options[hf][:html][:layout] if options[hf][:html].has_key?(:layout)

            html_string = externals_to_absolute_path(
                            render_to_string(options_for_render)
                          )
            f << html_string
            f.flush

            options[hf][:html].delete(:template)
            options[hf][:html][:url] = "file://#{f.path}"
            
            files_to_delete << f.path

          end
        end
      end

      options[:files_to_delete] = files_to_delete
      return options
    end

    def externals_to_absolute_path(html) 
      html.gsub(/(src|href)=('|")\//) { |s| "#{$1}=#{$2}#{request.protocol}#{request.host_with_port}/" }
    end
end
