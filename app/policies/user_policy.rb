class UserPolicy < ApplicationPolicy
  def index?          = admin?
  def show?           = admin? || dono?
  def update?         = admin? || dono?
  def destroy?        = admin?
  def alterar_role?   = admin?

  private

  def dono? = logado? && record.id == user.id
end
