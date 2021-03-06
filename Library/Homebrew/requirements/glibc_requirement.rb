require "requirement"

class GlibcRequirement < Requirement
  fatal true
  default_formula "glibc"
  @system_version = nil

  def self.system_version
    return @system_version if @system_version
    libc = ["/lib/x86_64-linux-gnu/libc.so.6", "/lib64/libc.so.6", "/usr/lib64/libc.so.6", "/lib/libc.so.6", "/usr/lib/libc.so.6", "/lib/i386-linux-gnu/libc.so.6", "/lib/arm-linux-gnueabihf/libc.so.6"].find do |s|
      Pathname.new(s).executable?
    end
    return Version::NULL unless libc
    version = Utils.popen_read("#{libc} 2>&1")[/[Vv]ersion (\d\.\d+)/, 1]
    return Version::NULL unless version
    @system_version = Version.new version
  end

  satisfy(build_env: false) do
    next true unless OS.linux?
    begin
      # The minimum version of glibc required to use Linuxbrew bottles.
      to_dependency.installed? ||
        Version.new(self.class.system_version.to_s) >= Version.new(to_dependency.to_formula.version)
    rescue FormulaUnavailableError
      true
    end
  end
end
