# coding: utf-8
namespace :test_user_data do
	desc '随机生成各类用户'

	task :test_users => :environment do
		role = Role.pluck(:id)
		50.times do |i|
			user = User.create(:email => "testuser_#{i}@test.com", :password => 'test1234')
			user.roles << Role.find(role[rand(0..(role.count-1))])
			p i if i % 2 == 0
		end
	end

end