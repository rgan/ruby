class TeamMember
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :length => 1..30
  property :facebook_id, String
  property :google_id, String

  belongs_to :team, :required => false

end