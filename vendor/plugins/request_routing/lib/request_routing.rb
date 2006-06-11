module ActionController
  module Routing
    class RouteSet
      def recognize(request)
        @request = request
        
        string_path = @request.path  
        string_path.chomp! if string_path[0] == ?/  
        path = string_path.split '/'  
        path.shift  
   
        hash = recognize_path(path)  
        return recognition_failed(@request) unless hash && hash['controller']  
   
        controller = hash['controller']  
        hash['controller'] = controller.controller_path  
        @request.path_parameters = hash  
        controller.new 
      end
       alias :recognize! :recognize
    end
    
    class Route
      REQUEST_CONDITIONS = %w{subdomain domain method port remote_ip content_type accepts request_uri protocol}.map &:to_sym
      
      def initialize(path, options = {})
        @path, @options = path, options

        initialize_components path
        defaults, conditions = initialize_hashes options.dup
        @defaults = defaults.dup
        @request_requirements = extract_request_requirements(conditions)
        configure_components(defaults, conditions)
        add_default_requirements
        initialize_keys
      end
  
      def write_recognition(generator = CodeGeneration::RecognitionGenerator.new)
        g = generator.dup
        g.share_locals_with generator
        g.before, g.current, g.after = [], components.first, (components[1..-1] || [])

        known.each do |key, value|
          if key == :controller then ControllerComponent.assign_controller(g, value)
          else g.constant_result(key, value)
          end
        end
        
        conds = @request_requirements.collect do |key, value|
          if value.is_a? Regexp
            "@request.#{ (key == :subdomain) ? "subdomains.first" : key.to_s } =~ #{value.inspect}"
          else
            "@request.#{ (key == :subdomain) ? "subdomains.first" : key.to_s } == #{value.inspect}"
          end
        end
        
        if !conds.empty?
          g.if(conds.join(' && ')) { |gp| gp.go }
        else
          g.go
        end

        generator
      end
      
      def extract_request_requirements(conditions)
        rr = {}
        conditions.each_pair do |key, value|
          rr[key] = conditions.delete(key) if REQUEST_CONDITIONS.include? key
        end
        rr
      end
      
    end
  end
end