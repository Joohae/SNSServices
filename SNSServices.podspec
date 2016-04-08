Pod::Spec.new do |spec|
  spec.name         = 'SNSServices'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/Joohae/SNSServices'
  spec.authors      = { 'Joohae Kim' => 'joohaek@gmail.com' }
  spec.summary      = 'ARC and GCD Compatible Reachability Class for iOS and OS X.'
  spec.source       = { :git => 'ihttps://github.com/Joohae/SNSServices.git', 
			:tag => '#{s.version}' 
			}
  spec.source_files = 'SNSServices/**/*.{h,m}'
  spec.resources    = 'SNSSErvices/*.xib'
  spec.framework    = 'SystemConfiguration'

  spec.platform     = :ios, "7.0"
  spec.dependency 'AFNetworking', '~> 3.0'
end
