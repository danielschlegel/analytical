module Analytical
  module Modules
    class Google
      include Analytical::Modules::Base

       # slot: 1-5 allowed
      # key: String
      # value: String
      # scope: 1 (visitor-level), 2 (session-level), or 3 (page-level)
      # custom_variables: Array of Objects :custom_variables => [{:slot => 1, :key => "key1", :value => "value1", :scope => 3}, {:slot => 2, :key => "key2", :value => "value2", :scope => 1}]
      def initialize(options={})
        super
        @tracking_command_location = :head_append
      end

      def init_javascript(location)
        init_location(location) do
          custom_variables = options[:custom_variables]
          if custom_variables
            custom_variable_string = ""
            custom_variables.each do |v|
              custom_variable_string << "_gaq.push(['_setCustomVar', #{v[:slot]}, #{v[:key]}, #{v[:value]}, #{v[:scope]}]);"
            end
          end
          js = <<-HTML
          <!-- Analytical Init: Google -->
          <script type="text/javascript">
            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', '#{options[:key]}']);
            _gaq.push(['_setDomainName', '#{options[:domain]}']);
            #{"_gaq.push(['_setAllowLinker', true]);" if options[:allow_linker]}
            #{"_gaq.push(['_trackPageLoadTime']);" if options[:track_page_load_time]}
          #{custom_variable_string if custom_variable_string}
            _gaq.push(['_trackPageview']);
            (function() {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
          </script>
          HTML
          js
        end
      end

      # slot: 1-5 allowed
      # key: String
      # value: String
      # scope: 1 (visitor-level), 2 (session-level), or 3 (page-level)
      def custom_variable(slot, key, value, scope)
        "_gaq.push(['_setCustomVar', #{slot}, #{key}, #{value}, #{scope} ]);"
      end

      def track(*args)
        "_gaq.push(['_trackPageview'#{args.empty? ? ']' : ', "' + args.first + '"]'});"
      end

      def event(name, *args)
        data = args.first || {}
        data = data[:value] if data.is_a?(Hash)
        data_string = !data.nil? ? ", #{data}" : ""
        "_gaq.push(['_trackEvent', \"Event\", \"#{name}\"" + data_string + "]);"
      end

    end
  end
end