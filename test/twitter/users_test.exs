defmodule Twitter.UsersTest do
  use Twitter.DataCase

  alias Twitter.Users

  describe "users" do
    alias Twitter.Users.User

    import Twitter.UsersFixtures

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user/1 returns the user with given id" do
      user_id = user_fixture().id

      assert {:ok, %User{id: ^user_id}} = Users.get_user(user_id)
    end

    test "subscribe/2 subscribes the user to the given user" do
      follower = user_fixture()
      followee = user_fixture()

      follower_id = follower.id
      followee_id = followee.id

      assert {:ok, %User{id: ^follower_id} = follower} = Users.subscribe(follower, followee)

      assert [%User{id: ^followee_id}] = follower.followees
    end

    test "subscribe/2 returns an error when the follower is already subscribed to the followee" do
      follower = user_fixture()
      followee = user_fixture()

      assert {:ok, _follower} = Users.subscribe(follower, followee)
      assert {:error, :already_subscribed} = Users.subscribe(follower, followee)
    end

    test "subscribe/2 returns an error when the follower is the same as the followee" do
      user = user_fixture()

      assert {:error, :cannot_subscribe_to_self} = Users.subscribe(user, user)
    end

    test "unsubscribe/2 unsubscribes the user from the given user" do
      follower = user_fixture()
      followee = user_fixture()

      assert {:ok, _follower} = Users.subscribe(follower, followee)
      assert {:ok, follower} = Users.unsubscribe(follower, followee)

      assert [] == follower.followees
    end

    test "unsubscribe/2 returns an error when the follower is not subscribed to the followee" do
      follower = user_fixture()
      followee = user_fixture()

      assert {:error, :not_found} = Users.unsubscribe(follower, followee)
    end

    test "unsubscribe/2 returns an error when the follower is the same as the followee" do
      user = user_fixture()

      assert {:error, :not_found} = Users.unsubscribe(user, user)
    end
  end
end
