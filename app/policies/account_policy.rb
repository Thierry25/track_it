# frozen_string_literal: true

# Policy to determine if account can view account details
class AccountPolicy
  def initialize(requestor, account)
    @requestor = requestor
    @account = account
  end

  def can_view?
    true if @requestor
  end

  def can_view_token?
    self_request?
  end

  def can_edit?
    self_request?
  end

  def can_delete?
    self_request?
  end

  def summary
    {
      can_view: can_view?,
      can_view_token: can_view_token?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  def self_request?
    @requestor == @account
  end
end
