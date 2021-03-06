module Pageflow
  class EntryDuplicate < Struct.new(:original_entry)
    def create!
      create_entry

      copy_draft
      copy_memberships

      new_entry
    end

    def self.of(entry)
      new(entry)
    end

    private

    attr_reader :new_entry

    def create_entry
      @new_entry = Entry.create!(new_attributes)
    end

    def copy_draft
      original_entry.draft.copy do |revision|
        revision.entry = new_entry
      end
    end

    def copy_memberships
      original_entry.users.each do |member|
        new_entry.memberships.create(user: member)
      end
    end

    def new_attributes
      {
        title: new_title,
        account: original_entry.account,
        theming: original_entry.theming,

        skip_draft_creation: true
      }
    end

    def new_title
      I18n.t('pageflow.entry.duplicated_title', title: original_entry.title)
    end
  end
end
