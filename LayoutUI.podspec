Pod::Spec.new do |s|
  s.name             = 'LayoutUI'
  s.version          = '0.0.2'
  s.summary          = 'Constraint-based autolayout system written on Swift. Not Autolayout wrapper. Reimplemenation of CGLayout.'

  s.description      = 'Powerful autolayout framework, that can manage UIView(NSView), CALayer and not rendered views.'

  s.homepage         = 'https://github.com/k-o-d-e-n/LayoutUI'
  s.screenshots     = 'https://raw.githubusercontent.com/k-o-d-e-n/LayoutUI/main/Resources/benchmark_chart.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Denis Koryttsev' => 'koden.u8800@gmail.com' }
  s.source           = { :git => 'https://github.com/k-o-d-e-n/LayoutUI.git', :branch => 'master' }
  s.social_media_url = 'https://twitter.com/K_o_D_e_N'
  # s.documentation_url = 'https://k-o-d-e-n.github.io/LayoutUI/'

  s.swift_version = '5.0'

  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Sources/LayoutUI/**.swift'
  s.exclude_files = 'Sources/LayoutUI/**.gyb.swift'
end
