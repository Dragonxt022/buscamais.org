class MediaFilePolicy < ApplicationPolicy
  def index?   = editor?
  def create?  = editor?
  def destroy? = admin? || dono?

  private

  def dono? = logado? && record.user_id == user.id
end
