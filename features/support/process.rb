class Aruba::SpawnProcess
  def exited?
    return true unless @process
    @process.exited?
  end
end
