#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require "spec_helper"

RSpec.describe "Session TTL",
               with_settings: { session_ttl_enabled?: true, session_ttl: "10" } do
  shared_let(:admin) { create(:admin) }
  let(:admin_password) { "adminADMIN!" }

  let!(:work_package) { create(:work_package) }

  before do
    login_with(admin.login, admin_password)
  end

  def expire!
    page.set_rack_session(updated_at: Time.now - 1.hour)
  end

  describe "outdated TTL on Rails request" do
    it "expires on the next Rails request" do
      visit "/my/account"
      expect(page).to have_css(".form--field-container", text: admin.login)

      # Expire the session
      expire!

      visit "/"
      expect(page).to have_css(".action-login")
    end
  end

  describe "outdated TTL on API request" do
    it "expires on the next APIv3 request" do
      page.driver.header("X-Requested-With", "XMLHttpRequest")
      visit "/api/v3/work_packages/#{work_package.id}"

      body = JSON.parse(page.body)
      expect(body["id"]).to eq(work_package.id)

      # Expire the session
      expire!
      visit "/api/v3/work_packages/#{work_package.id}"

      expect(page.body).to eq("unauthorized")
    end
  end
end
