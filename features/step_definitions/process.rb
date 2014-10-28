World(Aruba::Api)

Then "the interactive program is still running" do
  expect(@interactive.exited?).to be(false)
end

Then "the interactive program is not running" do
  expect(@interactive.exited?).to be(true)
end
