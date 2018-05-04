{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{            ����Ԫ���ڸ�����������Ԫ               }
{                                                       }
{*******************************************************}

unit HCTableCellData;

interface

uses
  Windows, HCRichData, HCCustomData, HCCommon;

type
  THCTableCellData = class(THCRichData)
  private
    FActive: Boolean;
  protected
    function GetHeight: Cardinal; override;
    procedure _FormatReadyParam(const AStartItemNo: Integer;
      var APrioDrawItemNo: Integer; var APos: TPoint); override;
    procedure SetActive(const Value: Boolean);
  public
    //constructor Create; override;
    /// <summary> ���������Ϊ������ҳ�Ⱦ������ӵĸ߶�(Ϊ���¸�ʽ��ʱ�������ƫ����) </summary>
    function ClearFormatExtraHeight: Integer;
    // ���ڱ����л��༭�ĵ�Ԫ��
    property Active: Boolean read FActive write SetActive;
  end;

implementation

uses
  HCRectItem, HCStyle; // debug��

{ THCTableCellData }

function THCTableCellData.ClearFormatExtraHeight: Integer;
var
  i, vFmtOffset, vFormatIncHight: Integer;
begin
  Result := 0;
  vFmtOffset := 0;
  for i := 1 to DrawItems.Count - 1 do
  begin
    if DrawItems[i].LineFirst then
    begin
      if DrawItems[i].Rect.Top <> DrawItems[i - 1].Rect.Bottom then
      begin
        vFmtOffset := DrawItems[i].Rect.Top - DrawItems[i - 1].Rect.Bottom;
        if vFmtOffset > Result then
          Result :=  vFmtOffset;
      end;
    end;

    OffsetRect(DrawItems[i].Rect, 0, -vFmtOffset);

    if Items[DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then  // RectItem������ڸ�ʽ��ʱ���к����м��ƫ�ƣ��¸�ʽ��ʱҪ�ָ����ɷ�ҳ�����ٴ����¸�ʽ�����ƫ��
    begin
      vFormatIncHight := (Items[DrawItems[i].ItemNo] as THCCustomRectItem).ClearFormatExtraHeight;
      DrawItems[i].Rect.Bottom := DrawItems[i].Rect.Bottom - vFormatIncHight;
    end;
  end;
end;

function THCTableCellData.GetHeight: Cardinal;
begin
  Result := inherited GetHeight;
  if DrawItems.Count > 0 then
    Result := Result + DrawItems[0].Rect.Top;
end;

procedure THCTableCellData.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
    FActive := Value;

  if not FActive then
  begin
    if Self.MouseDownItemNo >= 0 then
      Self.Items[Self.MouseDownItemNo].Active := False;
    Self.DisSelect;
    Self.Initialize;
    Style.UpdateInfoRePaint;
  end;
end;

procedure THCTableCellData._FormatReadyParam(const AStartItemNo: Integer;
  var APrioDrawItemNo: Integer; var APos: TPoint);
begin
  { �͸��಻ͬ��������Ϊ�漰��ҳʱ��ЩDrawItem������ƫ�ƣ��������¸�ʽ��ʱ
    ��ʼDrawItem�������ϴο�ҳ��ƫ�Ƶģ���Ӱ�챾�ε�λ�ü��㣬���Ա����ʽ��ʱ
    ȫ����0��ʼ����������˺�������Ҫ�˴��������򽫸����еĴ˺���ȡ���鷽�� }
  {APrioDrawItemNo := -1;
  APos.X := 0;
  APos.Y := 0;
  DrawItems.Clear; }
  inherited _FormatReadyParam(AStartItemNo, APrioDrawItemNo, APos);
end;

end.