namespace :temporary do
  # bundle exec rake temporary:backfill_invitation_inviter_administrator_and_role
  desc "既存の招待の inviter_id を inviter_administrator_id にコピーし、役割の無い招待をオーナーにする"
  task backfill_invitation_inviter_administrator_and_role: :environment do
    invitations = Invitation.where(inviter_administrator_id: nil).or(Invitation.where(role: nil))
    total = invitations.count
    puts "#{total} 件の招待を処理します"

    invitations.find_each.with_index(1) do |invitation, index|
      puts "[#{index}/#{total}] Invitation id=#{invitation.id}"
      invitation.backfill_inviter_administrator_and_role!
    end

    puts "完了しました"
  end
end
