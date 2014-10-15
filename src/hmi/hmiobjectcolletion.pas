unit hmiobjectcolletion;

interface

uses
  Classes, typinfo;

type
  {$IFDEF PORTUGUES}
  {:
  Implementa uma coleção de objetos.
  }
  {$ELSE}
  {:
  Object colletion class.
  }
  {$ENDIF}
  TObjectColletion = class(TCollection)
  private
    FOwner:TPersistent;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner:TComponent; ItemClass: TCollectionItemClass);
  end;

  {$IFDEF PORTUGUES}
  {:
  Implementa um item da coleção de objetos.
  }
  {$ELSE}
  {:
  Object colletion class item.
  }

  { TObjectColletionItem }
  {$ENDIF}
  TObjectColletionItem = Class(TCollectionItem)
  private
    FTargetObject: TComponent;
    FTargetObjectProperty: String;
    procedure SetTargetObject(AValue: TComponent);
    procedure SetTargetObjectProperty(AValue: String);
  protected
    fRequiredTypeName:String;
    function AcceptObject(obj:TComponent):Boolean; virtual;
    function AcceptObjectProperty(PropertyName:String):Boolean; virtual;
  published
    property TargetObject:TComponent read FTargetObject write SetTargetObject;
    property TargetObjectProperty:String read FTargetObjectProperty write SetTargetObjectProperty;
  public
    constructor Create(ACollection: TCollection); override;
  end;

implementation

{ TObjectColletion }

function TObjectColletion.GetOwner: TPersistent;
begin
  Result:=FOwner;
end;

constructor TObjectColletion.Create(AOwner: TComponent;
  ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
  FOwner:=AOwner;
end;

{ TObjectColletionItem }

procedure TObjectColletionItem.SetTargetObject(AValue: TComponent);
begin
  if FTargetObject=AValue then Exit;

  if AValue=nil then begin
    FTargetObject:=nil;
    FTargetObjectProperty:='';
    exit;
  end;

  if not AcceptObject(AValue) then exit;
  FTargetObject:=AValue;
  if Collection.Owner is TComponent then
    FTargetObject.FreeNotification(TComponent(Collection.Owner));
end;

procedure TObjectColletionItem.SetTargetObjectProperty(AValue: String);
begin
  if FTargetObjectProperty=AValue     then Exit;

  if AValue='' then begin
    FTargetObjectProperty:='';
    exit;
  end;

  if not Assigned(FTargetObject)      then exit;
  if not AcceptObject(FTargetObject)  then exit;
  if not AcceptObjectProperty(AValue) then exit;

  FTargetObjectProperty:=AValue;
end;

function TObjectColletionItem.AcceptObject(obj: TComponent): Boolean;
var
  PL: PPropList;
  tdata: PTypeData;
  nprops: Integer;
  p: Integer;
begin
  Result:=false;
  if not assigned(obj) then exit;
  tdata:=GetTypeData(obj.ClassInfo);

  GetMem(PL,tdata.PropCount*SizeOf(Pointer));
  try
    nprops:=GetPropList(obj,PL);
    for p:=0 to nprops-1 do begin
      if lowercase(PL^[p]^.PropType^.Name)=lowercase(fRequiredTypeName) then begin
        Result:=true;
        exit;
      end;
    end;
  finally
    Freemem(PL);
  end;
end;

function TObjectColletionItem.AcceptObjectProperty(PropertyName: String
  ): Boolean;
var
  PL: PPropList;
  tdata: PTypeData;
  nprops: Integer;
  p: Integer;
begin
  Result:=false;
  if not Assigned(FTargetObject) then exit;
  tdata:=GetTypeData(FTargetObject.ClassInfo);

  GetMem(PL,tdata.PropCount*SizeOf(Pointer));
  try
    nprops:=GetPropList(FTargetObject,PL);
    for p:=0 to nprops-1 do begin
      if (lowercase(PL^[p]^.Name)=lowercase(PropertyName)) and
         (lowercase(PL^[p]^.PropType^.Name)=lowercase(fRequiredTypeName)) then begin
        Result:=true;
        exit;
      end;
    end;
  finally
    Freemem(PL);
  end;
end;

constructor TObjectColletionItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  fRequiredTypeName:='';
end;

end.

