
class Wiedii

  autoload :Passwd, 'wiedii/passwd'
  autoload :System, 'wiedii/system'

  class Controller

    title = 'Users and passwords'

    get '/webif/admin/passwd.:format' do
      format(
        :path => '/webif/admin/passwd',
        :format => params[:format],
        :objects => nil,
        :title  => title
      )
    end

    put '/webif/admin/passwd.:format' do
      handle_errors do
        raise BadRequest, "Passwords do not match!"           if
            params[:newpasswd] != params[:newpasswd2]
        raise BadRequest, "Cannot accept an empty password!"  if
            params[:newpasswd].empty?
        if not Wiedii::Passwd.check_pass params[:oldpasswd]
          sleep 1
          raise Unauthorized, "Wrong password!"
        end
        Wiedii::Passwd.change_from_HTTP_request(params)
        msg[:info] = "Web interface password updated!"
        if params[:system] == 'on'
          root_user     = Wiedii::System::User.root
          current_user  = Wiedii::System::User.current
          root_user.passwd.change_from_HTTP_request(params) unless root_user.passwd.locked?
          current_user.passwd.change_from_HTTP_request(params)
          msg[:info] = "Password updated!"
              # Both, because if we are here,
              # webif passwd has been already updated...
        end
      end
      format(
        :path => '/webif/admin/passwd',
        :format => params[:format],
        :objects => nil,
        :title => title
      )
    end
  end
end
