require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  test "valid" do
    assert @user.valid?
  end

  test "user name " do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email check" do
    @user.email = "    "
    assert_not @user.valid?
  end

  test "name char limit" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email char limit" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
    first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
    @user.email = valid_address
    assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
    foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
    @user.email = invalid_address
    assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "user emails should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password is present " do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "minimum length for password" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? if user nil digest should return false" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    brian = users(:brian)
    alfred = users(:alfred)

    assert_not brian.following?(alfred)
    brian.follow(alfred)

    assert brian.following?(alfred)
    assert alfred.followers.include?(brian)

    brian.unfollow(alfred)
    assert_not brian.following?(alfred)
  end

  test "feed should have the right posts" do
    brian = users(:brian)
    alfred = users(:alfred)
    lana = users(:lana)

    # posts from the followed user
    lana.microposts.each do |post_following|
      assert brian.feed.include?(post_following)
    end

    # self-posts for user with followers
    brian.microposts.each do |post_self|
      assert brian.feed.include?(post_self)
    end

    # self-posts for user with no-followers
    alfred.microposts.each do |post_self|
      assert alfred.feed.include?(post_self)
    end

    # posts from unfollowed user
    lana.microposts.each do |post_self|
      assert lana.feed.include?(post_self)
    end
  end
end
