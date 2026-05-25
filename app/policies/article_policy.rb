class ArticlePolicy < ApplicationPolicy
  def index?   = true
  def show?    = record.publicado? || editor? || dono?

  def create?  = editor?
  def update?  = admin? || dono?
  def destroy? = admin? || dono?

  def publicar?  = editor?
  def arquivar?  = admin? || dono?
  def destacar?  = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.administrador? || user&.editor?
        scope.all
      else
        scope.publicados
      end
    end
  end

  private

  def dono? = logado? && record.author_id == user.id
end
