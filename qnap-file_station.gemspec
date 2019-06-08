Gem::Specification.new do |s|
	s.name         = "qnap-file_station"
	s.version      = "0.0.5"
	s.summary      = "Interface to the File Station API"
	s.description  = "Manage your files and folders in File Station"
	s.authors      = "cyclotron3k"
	s.files        = ["lib/qnap/file_station.rb", "lib/qnap/api_error.rb", "Rakefile", "qnap-file_station.gemspec", "README.md"]
	s.test_files   = ["test/test_file_station.rb"]
	s.homepage     = "https://github.com/cyclotron3k/qnap-file_station"
	s.license      = "MIT"
	s.required_ruby_version = ">= 1.9.0"
end
