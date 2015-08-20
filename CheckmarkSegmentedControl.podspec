Pod::Spec.new do |s|
  s.name             = "CheckmarkSegmentedControl"
  s.version          = "0.1.0"
  s.summary          = "CheckmarkSegmentedControl is a customisable alternative to UISegmentedControl."
  s.description      = "CheckmarkSegmentedControl is a customisable alternative to UISegmentedControl. Visually it looks like radio buttons group with checkmark sign in the middle and animated border on selection. Each option can be fully customised."

  s.homepage         = "https://github.com/gregttn/CheckmarkSegmentedControl"
  s.license          = 'MIT'
  s.author           = { "gregttn" => "gregttn@gmail.com" }
  s.source           = { :git => "https://github.com/gregttn/CheckmarkSegmentedControl.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gregttn'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.swift'
  s.resource_bundles = {
    'CheckmarkSegmentedControl' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'
end
