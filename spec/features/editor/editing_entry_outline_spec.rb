require 'spec_helper'

feature 'editing entry outline', :js => true do
  scenario 'adding a chapter' do
    user = Dom::Admin::Page.sign_in_as(:editor)
    entry = create(:entry, :title => 'Test Entry', :with_member => user)

    visit(pageflow.edit_entry_path(entry))
    Dom::Editor::EntryOutline.await!
    editor_sidebar = Dom::Editor::Sidebar.first
    editor_sidebar.add_chapter_button.click

    expect(editor_sidebar).to have_chapter_item
  end

  scenario 'removing a chapter' do
    user = Dom::Admin::Page.sign_in_as(:editor)
    entry = create(:entry, :title => 'Test Entry', :with_member => user)
    chapter = create(:chapter, :entry => entry, :title => 'Intro')

    visit(pageflow.edit_entry_path(entry))
    Dom::Editor::EntryOutline.await!
    Dom::Editor::ChapterItem.find_by_title('Intro').edit_link.click
    Dom::Editor::ChapterProperties.first.destroy_button.click

    expect(Dom::Editor::Sidebar.first).to have_no_chapter_item
  end

  scenario 'adding a page to a chapter' do
    user = Dom::Admin::Page.sign_in_as(:editor)
    entry = create(:entry, :title => 'Test Entry', :with_member => user)
    create(:chapter, :entry => entry, :title => 'Intro')

    visit(pageflow.edit_entry_path(entry))
    Dom::Editor::EntryOutline.await!
    chapter_item = Dom::Editor::ChapterItem.find_by_title('Intro')
    chapter_item.add_page_button.click

    expect(chapter_item).to have_page_item
  end

  scenario 'removing a page from a chapter' do
    user = Dom::Admin::Page.sign_in_as(:editor)
    entry = create(:entry, :title => 'Test Entry', :with_member => user)
    chapter = create(:chapter, :entry => entry, :title => 'Intro')
    create(:page, :chapter => chapter, :configuration => {:title => 'Welcome'})

    visit(pageflow.edit_entry_path(entry))
    Dom::Editor::EntryOutline.await!
    Dom::Editor::PageItem.find_by_title('Welcome').edit_link.click
    Dom::Editor::PageProperties.first.destroy_button.click

    expect(Dom::Editor::ChapterItem.find_by_title('Intro')).to have_no_page_item
  end
end
