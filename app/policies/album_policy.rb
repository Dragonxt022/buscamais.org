class AlbumPolicy < ApplicationPolicy
  def index?   = editor?
  def create?  = editor?
  def update?  = admin? || dono?
  def destroy? = admin? || dono?

  private

  def dono? = logado? && record.user_id == user.id
end
