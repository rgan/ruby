class Team
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true, :length => 1..30
  property :about, Text, :required => true, :length => 1..50

  has n, :team_members

  def candidates(friends)
      friends.select { |f| member = TeamMember.first(:name => f.name); member.nil? || member.team.nil? || member.team.id != self.id }
  end

  def add_member(name)
    errors = []
    member = TeamMember.first(:name => name)
    if member.nil?
      member = TeamMember.new(:name => name)
      if !member.save
        errors = member.errors.full_messages
      end
    end
    team_members << member
    save
    return errors
  end
end