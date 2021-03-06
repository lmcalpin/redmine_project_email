require_dependency 'mail_handler'
require 'dispatcher'

module MailerPatch
    def self.included(base) # :nodoc:
        base.send(:extend, ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            alias_method_chain :issue_add, :project_emission_email
            alias_method_chain :issue_edit, :project_emission_email
            alias_method_chain :document_added, :project_emission_email
            alias_method_chain :attachments_added, :project_emission_email
            alias_method_chain :news_added, :project_emission_email
            alias_method_chain :message_posted, :project_emission_email
            alias_method_chain :wiki_content_added, :project_emission_email
            alias_method_chain :wiki_content_updated, :project_emission_email
        end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def issue_add_with_project_emission_email(issue)
        from_project issue
        issue_add_without_project_emission_email issue
      end

      def issue_edit_with_project_emission_email(journal)
        issue = journal.journalized.reload
        from_project issue
        issue_edit_without_project_emission_email journal
      end

      def document_added_with_project_emission_email(document)
        from_project document
        document_added_without_project_emission_email document
      end

      def attachments_added_with_project_emission_email(container)
        container = attachments.first.container
        from_project container
        attachments_added_without_project_emission_email container
      end

      def news_added_with_project_emission_email(news)
        from_project news
        issue_add_without_project_emission_email news
      end

      def message_posted_with_project_emission_email(message)
        from_project message
        message_posted_without_project_emission_email message
      end

      def wiki_content_added_with_project_emission_email(wiki_content)
        from_project wiki_content
        wiki_content_added_without_project_emission_email wiki_content
      end

      def wiki_content_updated_with_project_emission_email(wiki_content)
        from_project wiki_content
        wiki_content_updated_without_project_emission_email wiki_content
      end

      def from_project(container)
		if container.present? && container.project.present? && container.project.mail_from.present?
          from container.project.mail_from
        end
      end
    end
end

Dispatcher.to_prepare do
  unless Mailer.included_modules.include?(MailerPatch)
    Mailer.send(:include, MailerPatch)
  end
end
