Pod::Spec.new do |s|

  s.name         = "MileWalletKit"
  s.version      = "0.8.0"
  s.summary      = "MileWalletKit is a SDK connects Mile nodes"
  s.description  = "MileWalletKit is a SDK helps to manage Mile wallets and interacts with Mile nodes."                   

  s.homepage     = "https://mile.global"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors            = { "denis svinarchuk" => "denn.nevera@gmail.com" }
  s.social_media_url   = "https://mile.global"

  s.platform     = :ios
  s.platform     = :osx

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.12"

  s.source       = { :git => "https://bitbucket.org/mile-core/mile-wallet-ios-kit", :tag => "#{s.version}" }

  s.source_files  = "mile-wallet-ios-kit/*.{h}", 
                    "mile-wallet-ios-kit/Classes/**/*.{swift}"
  #s.exclude_files = "" 

  s.public_header_files = "mile-wallet-ios-kit/*.{h}" 

  s.frameworks = "Foundation"
  s.libraries  = 'c++'

  s.swift_version = "4.2"

  s.dependency 'KeychainAccess'
  s.dependency 'JSONRPCKit'
  s.dependency 'APIKit'
  s.dependency 'ObjectMapper'
  s.dependency 'EFQRCode', '~> 4.2.2'
  s.dependency 'QRCodeReader.swift', '~> 8.2.0'
  s.dependency 'MileCsaLight'

  s.requires_arc = true

  s.compiler_flags = '-Wno-format', '-x objective-c++', '-DNDEBUG', '-DUSE_R128_FIXEDPOINT', '-DR128_STDC_ONLY'

  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'CSA=1' , 'OTHER_CFLAGS' => ''}
  
end
