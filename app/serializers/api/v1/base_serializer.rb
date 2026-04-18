class Api::V1::BaseSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at

  private

  def created_at
    object.created_at.utc.strftime('%Y-%m-%d %H:%M:%S')
  end

  def updated_at
    object.updated_at.utc.strftime('%Y-%m-%d %H:%M:%S')
  end
end
