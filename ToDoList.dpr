program ToDoList;

uses
  Vcl.Forms,
  UDashboard in 'UDashboard.pas' {DashboardUnit},
  ULogin in 'ULogin.pas' {LoginUnit},
  URegister in 'URegister.pas' {RegisterUnit},
  UTask in 'UTask.pas' {TaskUnit},
  UQuickReportAccount in 'UQuickReportAccount.pas' {F_QuickReportAccount},
  UQuickReportActivity in 'UQuickReportActivity.pas' {F_QuickReportActivity},
  UQuickReportTask in 'UQuickReportTask.pas' {F_QuickReportTask},
  UQuickReportLog in 'UQuickReportLog.pas' {F_QuickReportLog};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TLoginUnit, LoginUnit);
  //  Application.CreateForm(TQuickReportAccountUnit, QuickReportAccountUnit);
//  Application.CreateForm(TDashboardUnit, DashboardUnit);
//  Application.CreateForm(TRegisterUnit, RegisterUnit);
//  Application.CreateForm(TTaskUnit, TaskUnit);
//  Application.CreateForm(TQuickReportActivityUnit, QuickReportActivityUnit);
//  Application.CreateForm(TQuickReportTaskUnit, QuickReportTaskUnit);
//  Application.CreateForm(TQuickReportLogUnit, QuickReportLogUnit);
  Application.Run;
end.
