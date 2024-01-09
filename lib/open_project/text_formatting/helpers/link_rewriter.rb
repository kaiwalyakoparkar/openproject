#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
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

module OpenProject::TextFormatting
  module Helpers
    ##
    # Rewrite relative URLs to their absolute paths
    # when only_path is false.
    class LinkRewriter
      attr_reader :context

      def initialize(context)
        @context = context
      end

      ##
      # Test whether the given URL is relative and we need to replace it
      def applicable?(url)
        context[:only_path] == false && url.start_with?('/')
      end

      ##
      # Replace the given relative_url to an absolute URL
      # from the current context
      def replace(relative_url)
        protocol, host_with_port = determine_url_segments
        return relative_url unless protocol && host_with_port

        "#{protocol}#{host_with_port}#{relative_url}"
      end

      def determine_url_segments
        if request = context[:request]
          return [request.protocol, request.host_with_port]
        end

        url_opts = url_helpers.default_url_options
        ["#{url_opts[:protocol]}://", url_opts[:host]]
      end

      def url_helpers
        @url_helpers ||= OpenProject::StaticRouting::StaticUrlHelpers.new
      end
    end
  end
end
