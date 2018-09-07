class Artifact
  def initialize(source_path:, shared_path:, unshared_path:)
    @source_path = source_path
    @shared_path = shared_path
    @unshared_path = unshared_path
  end

  def eql?(other)
    [:@source_path, :@shared_path, :@unshared_path].index do |var|
      !instance_variable_get(var).eql?(other.instance_variable_get(var))
    end.nil?
  end

  attr_reader :source_path, :shared_path, :unshared_path
end
