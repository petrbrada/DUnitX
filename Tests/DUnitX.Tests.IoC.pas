{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DUnitX.Tests.IoC;

interface

uses
  DUnitX.TestFramework,
  DUnitX.IoC;

type
  {$M+}
  IFoo = interface
  ['{FA01B68C-0D64-4251-91C6-F38617A56B33}']
    procedure Bar;
  end;

  {$M+}
  ISingleton = interface
  ['{615BDB28-13D0-4CAF-B84A-3C77B479B9AE}']
    function HowMany : integer;
  end;

  TDUnitX_IoCTests = class
  public
    [SetupFixture]
     procedure Setup;

    {$IFDEF DELPHI_XE_UP}
    [Test]
    procedure Test_Implementation_Non_Singleton;

    [Test]
    procedure Test_Implementation_Singleton;
    {$ENDIF}

    [Test]
    procedure Test_Activator_Non_Singleton;

    [Test]
    procedure Test_Activator_Singleton;
  end;

implementation

type
  TFoo = class(TInterfacedObject,IFoo)
  protected
    procedure Bar;
  end;

{ TDUnitX_IoCTests }

procedure TDUnitX_IoCTests.Setup;
begin
  TDUnitXIoC.DefaultContainer.RegisterType<IFoo>(
      function : IFoo
      begin
        result := TFoo.Create;
      end);

  {$IFDEF DELPHI_XE_UP}
  //NOTE: DUnitX.IoC has details on why this is only available for XE up.
  TDUnitXIoC.DefaultContainer.RegisterType<IFoo,TFoo>('test');
  {$ENDIF}

  //singletons
  TDUnitXIoC.DefaultContainer.RegisterType<IFoo>(true,
      function : IFoo
      begin
        result := TFoo.Create;
      end,
      'activator_singleton');

  {$IFDEF DELPHI_XE_UP}
  //NOTE: DUnitX.IoC has details on why this is only available for XE up.
  TDUnitXIoC.DefaultContainer.RegisterType<IFoo,TFoo>(true,'impl_singleton');
  {$ENDIF}
end;

procedure TDUnitX_IoCTests.Test_Activator_Non_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>();
  foo2 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>();

  Assert.AreNotSame(foo1,foo2);
end;

procedure TDUnitX_IoCTests.Test_Activator_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>('activator_singleton');
  foo2 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>('activator_singleton');
  Assert.AreSame(foo1,foo2);

  {$IFDEF DELPHI_XE_UP}
  //NOTE: DUnitX.IoC has details on why this is only available for XE up.
  foo1 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>('impl_singleton');
  Assert.AreNotSame(foo1,foo2);
  {$ENDIF}
end;

{$IFDEF DELPHI_XE_UP}
//NOTE: DUnitX.IoC has details on why this is only available for XE up.
procedure TDUnitX_IoCTests.Test_Implementation_Non_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>('test');
  foo2 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>('test');
  Assert.AreNotSame(foo1,foo2);
end;

procedure TDUnitX_IoCTests.Test_Implementation_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>('impl_singleton');
  foo2 := TDUnitXIoC.DefaultContainer.Resolve<IFoo>('impl_singleton');
  Assert.AreSame(foo1,foo2);
end;
{$ENDIF}

{ TFoo }

procedure TFoo.Bar;
begin
  Write('Bar');
end;

initialization
  TDUnitX.RegisterTestFixture(TDUnitX_IoCTests);
end.
