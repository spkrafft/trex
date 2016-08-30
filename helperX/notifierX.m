function varargout = notifierX(project_path,fh,varargin)
% notifier - Notifies you via email when a function finishes.
%
% USAGE:
%   varargout = notifier(fh, varargin)
%
% INPUT:
%   fh         - Function handle for the sub function to run.
%   varargin   - Input arguments passed directly to the sub function.
%
% OUTPUT:
%   varargout  - Output from the sub funtion is passed directly as output
%                from this function.
%
% EXAMPLE:
%   Without notifier:
%       output = myfunc(arg1, arg2, arg3)
%   With notifier:
%       output = notifier(@myfunc, arg1, arg2, arg3)
%
% AUTHOR: Benjamin Kraus (bkraus@bu.edu, ben@benkraus.com)
% Copyright (c) 2010, Benjamin Kraus
% $Id: notifier.m 1788 2010-09-17 01:41:46Z bkraus $

%%
mail = setupGmailNotifierX;

if ~isempty(mail)
    t = datestr(now,'HH:MM:SS mm/dd/yyyy');
    sendmail(mail,['Starting ',func2str(fh),' at ',t],project_path);

    % Put the actual function call in a try-catch block, so you are
    % notified in case of errors.
    try
        [varargout{1:nargout}] = fh(varargin{:});
    catch ME1
        % Put sendmail in a try-catch block, so that you don't lose the results
        % of the function call if sendmail throws an error.
        try
            t = datestr(now,'HH:MM:SS mm/dd/yyyy');
            sendmail(mail,[func2str(fh),' threw an error at ',t,ME1.identifier,'.'],[project_path,'...',ME1.message]);
        catch ME2
            warning('Notifier:SendmailError','Sendmail threw an error. Check sendmail before running again.');
            warning('Nofifier:SendmailError',ME2.message);
        end
        rethrow(ME1);
    end

    % Put sendmail in a try-catch block, so that you don't lose the results
    % of the function call if sendmail throws an error.
    t = datestr(now,'HH:MM:SS mm/dd/yyyy');
    try
        sendmail(mail,[func2str(fh),' finished successfully at ',t,'.'],project_path);
    catch ME3
        warning('Notifier:SendmailError','Sendmail threw an error. Check sendmail before running again.');
        warning('Nofifier:SendmailError',ME3.message);
    end
else
    [varargout{1:nargout}] = fh(varargin{:});
end

%--------------------------------------------------------------------------
function mail = setupGmailNotifierX
%%
mainDir = fileparts(which('TREX'));
configPath = fullfile(mainDir,'config.trex');

fid = fopen(configPath);
config = textscan(fid,'%s','delimiter','\n');
config = config{1};
fclose(fid);

mail = textParserX(config,'notifier-mail'); %Your GMail email address
password = textParserX(config,'notifier-password'); %Your GMail password

if isempty(mail) || strcmpi(mail,'') || isempty(password) || strcmpi(password,'')
    mail = [];
else
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','E_mail',mail);
    setpref('Internet','SMTP_Username',mail);
    setpref('Internet','SMTP_Password',password);

    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
end

clearvars -except mail
