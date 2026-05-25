class CommentPolicy < ApplicationPolicy
  def index?   = editor?
  def show?    = editor?
  def create?  = logado?
  def update?  = admin? || dono?
  def destroy? = admin? || dono?

  def aprovar?  = editor?
  def rejeitar? = editor?

  private

  def dono? = logado? && record.user_id == user.id
end
