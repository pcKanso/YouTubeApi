Pod::Spec.new do |s|
  s.name                = 'YouTubeApi'
  s.version             = '0.0.1'
  s.platform            = :ios, '8.0'
  s.homepage            = 'https://github.com/turok/YouTubeApi'
  s.authors             = { 'Anton Turko' => 'tohaturok@gmail.com' }
  s.license             = { :type => 'MIT' }
  s.summary             = 'Wrapper for Google YouTube Data API.'
  s.source              = { :git => 'https://github.com/turok/YouTubeApi.git' }
  s.dependency          'GTMAppAuth'
  s.dependency          'GoogleAPIClient/YouTube'
  s.vendored_frameworks = 'YouTubeApi.framework'
  s.source_files        = 'YouTubeApi/*.{h,m}', 'YouTubeApi/Model/*.{h,m}'
end