class ActiveRecord::Base
   
  def business_name
		nil
	end
  
end

module ActionView
  module Helpers
    module ActiveRecordHelper
      DEFAULT_PARTIAL = %{
        <div>
          <div class="errorExplanation" id="errorExplanation">
            <h2><%= pluralize(errors.size, "error") %> <%= errors.size == 1 ? "needs" : "need" %> to be fixed.</h2>
            <ul>
              <% for error in errors -%>
                <li><%= error %></li>
              <% end -%>  
            </ul>
          </div>
        </div>
      }
      
      alias_method :old_error_messages_for, :error_messages_for
      
      def error_messages_for(object_names = [], view_partial = nil)
        object_names = [object_names]
        object_names.flatten!
        app_errors = []
        object_names.each do |name| 
          object = instance_variable_get("@#{name}")
          if object
            object.errors.each do |key, value|
              if value.match(/^\^/)
                unless value.match(/^\^nil/)
                  app_errors << value[1..value.length]
                end
              else
                if key.class == String and key == "base"
                  app_errors << "#{value}"
                else
									unless object.business_name.blank?
										app_errors << "#{object.business_name} #{key.underscore.split('_').join(' ').humanize} #{value}"
                  else
										app_errors << "#{key.underscore.split('_').join(' ').humanize} #{value}"
									end
								end
              end
            end
          end
        end
        
        unless app_errors.empty?
          if view_partial.nil?
            if File.exist?("#{RAILS_ROOT}/app/views/application/_error_messages.rhtml")
              render :partial => "application/error_messages", :locals => {:errors => app_errors}
            else
              render :inline => DEFAULT_PARTIAL, :locals => {:errors => app_errors}
            end
          else        
            render :partial => view_partial, :locals => {:errors => app_errors}
          end
        else
          ""
        end
      end
      
    end
  end
end