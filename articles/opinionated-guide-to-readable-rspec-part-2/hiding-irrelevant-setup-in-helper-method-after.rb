context 'when notifications service is disabled' do
  it 'does not create project deletion notification for user' do
    allow(notifier_client_double).to receive(:active?) { false }
    user = create(:user)
    project = create(:project, name: "Zebra", owner: user)

    expect { DestroyProject.call(project) }.to_not change { Notification.count }
  end
end

context 'when notifications service is active' do
  it 'creates project deletion notification for user' do
    allow(notifier_client_double).to receive(:active?) { true }
    user = create(:user)
    project = create(:project, name: "Zebra", owner: user)

    expect { DestroyProject.call(project) }.to change { Notification.count }.from(0).to(1)

    expect(Notification.last).to have_attributes(
      user: user,
      text: 'Project Zebra has been removed'
    )
  end
end

def notifier_client_double
  api_user = create(:user, :api)
  api_user_account = create(:account, user: api_user)
  notifier_client = instance_double(NotifierClient)
  allow(NotifierClient).to receive(:for).with(api_user_account) { notifier_client }
end
