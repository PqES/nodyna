class BasicProcess < SexpInterpreter

    def initialize(relatedFile)
        super()
        self.default_method = "process_nothing"
        self.warn_on_default = false
        @relatedFile = relatedFile
    end
end