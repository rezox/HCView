{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  �ĵ��ڻ���ʵ�ֵ�Ԫ                   }
{                                                       }
{*******************************************************}

unit HCCustomSection;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, HCRichData, HCSectionData,
  HCCustomRichData, HCTextStyle, HCParaStyle, HCItem, HCDrawItem, HCPage, HCCommon,
  HCStyle, HCCustomData, HCUndo;

type
  TPrintResult = (prOk, prNoPrinter, prNoSupport, prError);

  TSectionPaintInfo = class(TPaintInfo)
  strict private
    FSectionIndex, FPageIndex: Integer;
    FPageDrawRight: Integer;
  public
    property SectionIndex: Integer read FSectionIndex write FSectionIndex;
    property PageIndex: Integer read FPageIndex write FPageIndex;
    property PageDrawRight: Integer read FPageDrawRight write FPageDrawRight;
  end;

  TSectionPagePaintEvent = procedure(Sender: TObject; const APageIndex: Integer;
    const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo) of object;

  THCCustomSection = class(TObject)
  private
    FStyle: THCStyle;

    /// <summary> �Ƿ�ԳƱ߾� </summary>
    FSymmetryMargin: Boolean;
    FPages: THCPages;  // ����ҳ��
    FPageSize: THCPageSize;
    FPageOrientation: TPageOrientation;
    FHeader: THCHeaderData;
    FFooter: THCFooterData;
    FPageData: THCPageData;
    FActiveData: THCSectionData;  // ҳü�����ġ�ҳ��

    FPageNoVisible: Boolean;  // �Ƿ���ʾҳ��

    FPageNoFrom,  // ҳ��Ӽ���ʼ
    FActivePageIndex,  // ��ǰ�����ҳ
    FMousePageIndex,  // ��ǰ�������ҳ
    FDisplayFirstPageIndex,  // ���Ե�һҳ
    FDisplayLastPageIndex,   // �������һҳ
    FHeaderOffset  // ҳü����ƫ��
      : Integer;

    FOnDataChanged,  // ҳü��ҳ�š�ҳ��ĳһ���޸�ʱ����
    FOnCheckUpdateInfo,  // ��ǰData��ҪUpdateInfo����ʱ����
    FOnReadOnlySwitch  // ҳü��ҳ�š�ҳ��ֻ��״̬�����仯ʱ����
      : TNotifyEvent;

    FOnGetScreenCoord: TGetScreenCoordEvent;

    FOnPaintHeader, FOnPaintFooter, FOnPaintPage, FOnPaintWholePage: TSectionPagePaintEvent;
    FOnItemPaintBefor, FOnItemPaintAfter: TItemPaintEvent;
    FOnDrawItemPaintAfter: TDrawItemPaintEvent;
    FOnInsertItem: TItemNotifyEvent;
    FOnItemResized: TDataItemEvent;
    FOnCreateItem: TNotifyEvent;
    FOnCreateItemByStyle: TStyleItemEvent;
    FOnGetUndoList: TGetUndoListEvent;

    /// <summary> ���ص�ǰ��ָ���Ĵ�ֱƫ�ƴ���Ӧ��ҳ </summary>
    /// <param name="AVOffset">��ֱƫ��</param>
    /// <returns>ҳ��ţ�-1��ʾ�޶�Ӧҳ</returns>
    function GetPageIndexByFilm(const AVOffset: Integer): Integer;

    function GetPageIndexByFmt(const AVOffset: Integer): Integer;

    /// <summary> ��ǰData��ҪUpdateInfo���� </summary>
    procedure DoActiveDataCheckUpdateInfo;

    procedure DoDataReadOnlySwitch(Sender: TObject);
    function DoGetScreenCoordEvent(const X, Y: Integer): TPoint;
    procedure DoDataItemPaintBefor(const AData: THCCustomData;
      const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
    procedure DoDataItemPaintAfter(const AData: THCCustomData;
      const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo);

    procedure DoDataDrawItemPaintAfter(const AData: THCCustomData;
      const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo);

    procedure DoDataInsertItem(const AItem: THCCustomItem);

    /// <summary> ����ItemԼ����Ҫ������ҳ������ </summary>
    procedure DoDataItemResized(const AData: THCCustomData; const AItemNo: Integer);
    function DoDataCreateStyleItem(const AStyleNo: Integer): THCCustomItem;
    procedure DoDataCreateItem(Sender: TObject);
    function DoDataGetUndoList: THCUndoList;

    /// <summary> ����ҳ��Dataָ��DrawItem���ڵ�ҳ(��ҳ�İ����λ������ҳ) </summary>
    /// <param name="ADrawItemNo"></param>
    /// <returns></returns>
    function GetPageIndexByDrawItem(const ADrawItemNo: Integer): Integer;

    /// <summary> ��ĳһҳ������ת����ҳָ��Data������(�˷�����ҪAX��AY�ڴ�ҳ�ϵ�ǰ��) </summary>
    /// <param name="APageIndex"></param>
    /// <param name="AData"></param>
    /// <param name="AX"></param>
    /// <param name="AY"></param>
    /// <param name="ARestrain">�Ƿ�Լ����Data�ľ���������</param>
    procedure PageCoordToData(const APageIndex: Integer;
      const AData: THCRichData; var AX, AY: Integer;
      const ARestrain: Boolean = False);

    function GetReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
  protected
    procedure Clear; virtual;

    /// <summary> ����ָ��ҳ��ָ����λ�ã�Ϊ��ϴ�ӡ������ADisplayWidth, ADisplayHeight���� </summary>
    /// <param name="APageIndex">Ҫ���Ƶ�ҳ��</param>
    /// <param name="ALeft">����Xƫ��</param>
    /// <param name="ATop">����Yƫ��</param>
    /// <param name="ACanvas"></param>
    procedure PaintPage(const APageIndex, ALeft, ATop: Integer;
      const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo); virtual;

    /// <summary> ��ȡ�����Dtat�е�λ����Ϣ��ӳ�䵽ָ��ҳ�� </summary>
    /// <param name="APageIndex">Ҫӳ�䵽��ҳ���</param>
    /// <param name="ACaretInfo">���λ����Ϣ</param>
    procedure GetPageCaretInfo(var ACaretInfo: TCaretInfo); virtual;
    //
    procedure KillFocus;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;

    procedure DoDataChanged(Sender: TObject);

    // ֽ����Ϣ
    function GetPaperSize: Integer;
    procedure SetPaperSize(const Value: Integer);
    // �߾���Ϣ
    function GetPaperWidth: Single;
    function GetPaperHeight: Single;
    function GetPaperMarginTop: Single;
    function GetPaperMarginLeft: Single;
    function GetPaperMarginRight: Single;
    function GetPaperMarginBottom: Single;

    procedure SetPaperWidth(const Value: Single);
    procedure SetPaperHeight(const Value: Single);
    procedure SetPaperMarginTop(const Value: Single);
    procedure SetPaperMarginLeft(const Value: Single);
    procedure SetPaperMarginRight(const Value: Single);
    procedure SetPaperMarginBottom(const Value: Single);
    procedure SetPageOrientation(const Value: TPageOrientation);

    function GetPageWidthPix: Integer;
    function GetPageHeightPix: Integer;
    function GetPageMarginTopPix: Integer;
    function GetPageMarginLeftPix: Integer;
    function GetPageMarginRightPix: Integer;
    function GetPageMarginBottomPix: Integer;

    procedure SetPageWidthPix(const Value: Integer);
    procedure SetPageHeightPix(const Value: Integer);
    procedure SetPageMarginTopPix(const Value: Integer);
    procedure SetPageMarginLeftPix(const Value: Integer);
    procedure SetPageMarginRightPix(const Value: Integer);
    procedure SetPageMarginBottomPix(const Value: Integer);
    procedure SetHeaderOffset(const Value: Integer);
    function NewEmptyPage: THCPage;
    function GetPageCount: Integer;

    function GetSectionDataAt(const X, Y: Integer): THCSectionData;
    function GetActiveArea: TSectionArea;
    procedure SetActiveData(const Value: THCSectionData);

    /// <summary> �������ݸ�ʽ��AVerticalλ���ڽ����е�λ�� </summary>
    /// <param name="AVertical"></param>
    /// <returns></returns>
    function GetDataFmtTopFilm(const AVertical: Integer): Integer;
    function ActiveDataChangeByAction(const AFunction: THCFunction): Boolean;

    property Style: THCStyle read FStyle;
  public
    constructor Create(const AStyle: THCStyle);
    destructor Destroy; override;
    //
    /// <summary> �޸�ֽ�ű߾� </summary>
    procedure ResetMargin;
    procedure DisActive;
    function SelectExists: Boolean;
    procedure SelectAll;
    function GetHint: string;
    function GetCurItem: THCCustomItem;
    function GetTopLevelItem: THCCustomItem;
    function GetTopLevelDrawItem: THCCustomDrawItem;
    function GetActiveDrawItemCoord: TPoint;

    /// <summary> ���ع������ҳ��� </summary>
    function GetCurrentPageIndex: Integer;
    procedure PaintDisplayPage(const AFilmOffsetX, AFilmOffsetY: Integer;
      const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);

    procedure KeyPress(var Key: Char);
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    procedure KeyUp(var Key: Word; Shift: TShiftState);
    //
    procedure ApplyTextStyle(const AFontStyle: TFontStyleEx);
    procedure ApplyTextFontName(const AFontName: TFontName);
    procedure ApplyTextFontSize(const AFontSize: Single);
    procedure ApplyTextColor(const AColor: TColor);
    procedure ApplyTextBackColor(const AColor: TColor);

    function InsertText(const AText: string): Boolean;
    function InsertTable(const ARowCount, AColCount: Integer): Boolean;
    function InsertLine(const ALineHeight: Integer): Boolean;
    function InsertItem(const AItem: THCCustomItem): Boolean; overload;
    function InsertItem(const AIndex: Integer; const AItem: THCCustomItem): Boolean; overload;

    /// <summary> �ӵ�ǰλ�ú��� </summary>
    function InsertBreak: Boolean;

    /// <summary> �ӵ�ǰλ�ú��ҳ </summary>
    function InsertPageBreak: Boolean;

    /// <summary> ��ǰѡ�е�����������ע </summary>
    function InsertAnnotate(const AText: string): Boolean;
    //
    function ActiveTableInsertRowAfter(const ARowCount: Byte): Boolean;
    function ActiveTableInsertRowBefor(const ARowCount: Byte): Boolean;
    function ActiveTableDeleteCurRow: Boolean;
    function ActiveTableInsertColAfter(const AColCount: Byte): Boolean;
    function ActiveTableInsertColBefor(const AColCount: Byte): Boolean;
    function ActiveTableDeleteCurCol: Boolean;
    //
    //// <summary>  ������ת����ָ��ҳ���� </summary>
    procedure SectionCoordToPage(const APageIndex, X, Y: Integer; var
      APageX, APageY: Integer);

    /// <summary> Ϊ��Ӧ�ö��뷽ʽ </summary>
    /// <param name="AAlign">�Է���ʽ</param>
    procedure ApplyParaAlignHorz(const AAlign: TParaAlignHorz);
    procedure ApplyParaAlignVert(const AAlign: TParaAlignVert);
    procedure ApplyParaBackColor(const AColor: TColor);
    procedure ApplyParaLineSpace(const ASpace: Integer);

    /// <summary> ĳҳ���������е�Topλ�� </summary>
    /// <param name="APageIndex"></param>
    /// <returns></returns>
    function GetPageTopFilm(const APageIndex: Integer): Integer;

    /// <summary> ����ָ��ҳ������ʼλ��������Data�е�Top��ע�� 20161216001 </summary>
    /// <param name="APageIndex"></param>
    /// <returns></returns>
    function GetPageDataFmtTop(const APageIndex: Integer): Integer;

    /// <summary> ҳü������ҳ�е���ʼλ�� </summary>
    /// <returns></returns>
    function GetHeaderPageDrawTop: Integer;

    function GetPageMarginLeft(const APageIndex: Integer): Integer;

    /// <summary> ����ҳ��Գ����ԣ���ȡָ��ҳ�����ұ߾� </summary>
    /// <param name="APageIndex"></param>
    /// <param name="AMarginLeft"></param>
    /// <param name="AMarginRight"></param>
    procedure GetPageMarginLeftAndRight(const APageIndex: Integer;
      var AMarginLeft, AMarginRight: Integer);

    /// <summary> ������ָ��Item��ʼ���¼���ҳ </summary>
    /// <param name="AStartItemNo"></param>
    procedure BuildSectionPages(const AStartItemNo: Integer);
    function DeleteSelected: Boolean;
    procedure DisSelect;
    function MergeTableSelectCells: Boolean;
    procedure ReFormatActiveItem;
    function GetHeaderAreaHeight: Integer;
    function GetContentHeight: Integer;
    function GetContentWidth: Integer;
    function GetFilmHeight: Cardinal;  // ����ҳ���+�ָ���
    function GetFilmWidth: Cardinal;

    /// <summary> �����ʽ�Ƿ����û�ɾ����ʹ�õ���ʽ��������ʽ��� </summary>
    /// <param name="AMark">True:�����ʽ�Ƿ����ã�Fasle:����ԭ��ʽ��ɾ����ʹ����ʽ��������</param>
    procedure MarkStyleUsed(const AMark: Boolean;
      const AParts: TSaveParts = [saHeader, saData, saFooter]);
    procedure SaveToStream(const AStream: TStream;
      const ASaveParts: TSaveParts = [saHeader, saData, saFooter]);
    procedure LoadFromText(const AFileName: string; const AEncoding: TEncoding);
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word);
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean;
    procedure FormatData;
    procedure Undo(const AUndo: THCUndo);
    procedure Redo(const ARedo: THCUndo);
    // ����
    // ҳ��
    property PaperSize: Integer read GetPaperSize write SetPaperSize;
    property PaperWidth: Single read GetPaperWidth write SetPaperWidth;
    property PaperHeight: Single read GetPaperHeight write SetPaperHeight;
    property PaperMarginTop: Single read GetPaperMarginTop write SetPaperMarginTop;
    property PaperMarginLeft: Single read GetPaperMarginLeft write SetPaperMarginLeft;
    property PaperMarginRight: Single read GetPaperMarginRight write SetPaperMarginRight;
    property PaperMarginBottom: Single read GetPaperMarginBottom write SetPaperMarginBottom;
    property PageOrientation: TPageOrientation read FPageOrientation write SetPageOrientation;
    //
    property PageWidthPix: Integer read GetPageWidthPix write SetPageWidthPix;
    property PageHeightPix: Integer read GetPageHeightPix write SetPageHeightPix;
    property PageMarginTopPix: Integer read GetPageMarginTopPix write SetPageMarginTopPix;
    property PageMarginLeftPix: Integer read GetPageMarginLeftPix write SetPageMarginLeftPix;
    property PageMarginRightPix: Integer read GetPageMarginRightPix write SetPageMarginRightPix;
    property PageMarginBottomPix: Integer read GetPageMarginBottomPix write SetPageMarginBottomPix;

    property HeaderOffset: Integer read FHeaderOffset write SetHeaderOffset;
    property Header: THCHeaderData read FHeader;
    property Footer: THCFooterData read FFooter;
    property PageData: THCPageData read FPageData;

    /// <summary> ��ǰ�ĵ���������(ҳü��ҳ�š�ҳ��)�����ݶ��� </summary>
    property ActiveData: THCSectionData read FActiveData write SetActiveData;

    /// <summary> ��ǰ�ĵ���������ҳü��ҳ�š�ҳ�� </summary>
    property ActiveArea: TSectionArea read GetActiveArea;
    property ActivePageIndex: Integer read FActivePageIndex;

    /// <summary> �Ƿ�ԳƱ߾� </summary>
    property SymmetryMargin: Boolean read FSymmetryMargin write FSymmetryMargin;
    property DisplayFirstPageIndex: Integer read FDisplayFirstPageIndex write FDisplayFirstPageIndex;  // ���Ե�һҳ
    property DisplayLastPageIndex: Integer read FDisplayLastPageIndex write FDisplayLastPageIndex;  // �������һҳ
    property PageCount: Integer read GetPageCount;
    property PageNoVisible: Boolean read FPageNoVisible write FPageNoVisible;
    property PageNoFrom: Integer read FPageNoFrom write FPageNoFrom;

    /// <summary> �ĵ����в����Ƿ�ֻ�� </summary>
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property OnDataChanged: TNotifyEvent read FOnDataChanged write FOnDataChanged;
    property OnReadOnlySwitch: TNotifyEvent read FOnReadOnlySwitch write FOnReadOnlySwitch;
    property OnGetScreenCoord: TGetScreenCoordEvent read FOnGetScreenCoord write FOnGetScreenCoord;
    property OnCheckUpdateInfo: TNotifyEvent read FOnCheckUpdateInfo write FOnCheckUpdateInfo;
    property OnInsertItem: TItemNotifyEvent read FOnInsertItem write FOnInsertItem;
    property OnItemResized: TDataItemEvent read FOnItemResized write FOnItemResized;
    property OnPaintHeader: TSectionPagePaintEvent read FOnPaintHeader write FOnPaintHeader;
    property OnPaintFooter: TSectionPagePaintEvent read FOnPaintFooter write FOnPaintFooter;
    property OnPaintPage: TSectionPagePaintEvent read FOnPaintPage write FOnPaintPage;
    property OnPaintWholePage: TSectionPagePaintEvent read FOnPaintWholePage write FOnPaintWholePage;
    property OnItemPaintBefor: TItemPaintEvent read FOnItemPaintBefor write FOnItemPaintBefor;
    property OnItemPaintAfter: TItemPaintEvent read FOnItemPaintAfter write FOnItemPaintAfter;
    property OnDrawItemPaintAfter: TDrawItemPaintEvent read FOnDrawItemPaintAfter write FOnDrawItemPaintAfter;
    property OnCreateItem: TNotifyEvent read FOnCreateItem write FOnCreateItem;
    property OnCreateItemByStyle: TStyleItemEvent read FOnCreateItemByStyle write FOnCreateItemByStyle;
    property OnGetUndoList: TGetUndoListEvent read FOnGetUndoList write FOnGetUndoList;
  end;

implementation

uses
  Math, HCRectItem;

{ THCCustomSection }

function THCCustomSection.ActiveTableDeleteCurCol: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.ActiveTableDeleteCurCol;
    end);
end;

function THCCustomSection.ActiveTableDeleteCurRow: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.ActiveTableDeleteCurRow;
    end);
end;

function THCCustomSection.ActiveTableInsertColAfter(const AColCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertColAfter(AColCount);
    end);
end;

function THCCustomSection.ActiveTableInsertColBefor(const AColCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertColBefor(AColCount);
    end);
end;

function THCCustomSection.ActiveTableInsertRowAfter(const ARowCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertRowAfter(ARowCount);
    end);
end;

function THCCustomSection.ActiveTableInsertRowBefor(const ARowCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertRowBefor(ARowCount);
    end);
end;

procedure THCCustomSection.ApplyParaAlignHorz(const AAlign: TParaAlignHorz);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaAlignHorz(AAlign);
    end);
end;

procedure THCCustomSection.ApplyParaAlignVert(const AAlign: TParaAlignVert);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaAlignVert(AAlign);
    end);
end;

procedure THCCustomSection.ApplyParaBackColor(const AColor: TColor);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaBackColor(AColor);
    end);
end;

procedure THCCustomSection.ApplyParaLineSpace(const ASpace: Integer);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaLineSpace(ASpace);
    end);
end;

procedure THCCustomSection.ApplyTextBackColor(const AColor: TColor);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextBackColor(AColor);
    end);
end;

procedure THCCustomSection.ApplyTextColor(const AColor: TColor);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextColor(AColor);
    end);
end;

procedure THCCustomSection.ApplyTextFontName(const AFontName: TFontName);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextFontName(AFontName);
    end);
end;

procedure THCCustomSection.ApplyTextFontSize(const AFontSize: Single);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextFontSize(AFontSize);
    end);
end;

procedure THCCustomSection.ApplyTextStyle(const AFontStyle: TFontStyleEx);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextStyle(AFontStyle);
    end);
end;

procedure THCCustomSection.Clear;
begin
  FHeader.Clear;
  FFooter.Clear;
  FPageData.Clear;
  FPages.ClearEx;
  FActivePageIndex := 0;
end;

constructor THCCustomSection.Create(const AStyle: THCStyle);
var
  vWidth: Integer;

  procedure SetDataProperty(const AData: THCSectionData);
  begin
    AData.Width := vWidth;
    AData.OnInsertItem := DoDataInsertItem;
    AData.OnItemResized := DoDataItemResized;
    AData.OnCreateItemByStyle := DoDataCreateStyleItem;
    AData.OnCreateItem := DoDataCreateItem;
    AData.OnReadOnlySwitch := DoDataReadOnlySwitch;
    AData.OnGetScreenCoord := DoGetScreenCoordEvent;
    AData.OnItemPaintBefor := DoDataItemPaintBefor;
    AData.OnItemPaintAfter := DoDataItemPaintAfter;
    AData.OnDrawItemPaintAfter := DoDataDrawItemPaintAfter;
    AData.OnGetUndoList := DoDataGetUndoList;
  end;

begin
  inherited Create;
  FStyle := AStyle;
  FPageNoVisible := True;
  FPageNoFrom := 1;
  FHeaderOffset := 20;
  FDisplayFirstPageIndex := -1;
  FDisplayLastPageIndex := -1;

  FPageSize := THCPageSize.Create(AStyle.PixelsPerMMX, AStyle.PixelsPerMMY);
  FPageOrientation := TPageOrientation.cpoPortrait;
  vWidth := GetContentWidth;

  FPageData := THCPageData.Create(AStyle);
  SetDataProperty(FPageData);

  // FData.PageHeight := PageHeightPix - PageMarginBottomPix - GetHeaderAreaHeight;
  // ��ReFormatSectionData�д�����FData.PageHeight

  FHeader := THCHeaderData.Create(AStyle);
  SetDataProperty(FHeader);

  FFooter := THCFooterData.Create(AStyle);
  SetDataProperty(FFooter);

  FActiveData := FPageData;
  FSymmetryMargin := True;  // �Գ�ҳ�߾� debug

  FPages := THCPages.Create;
  NewEmptyPage;           // �����հ�ҳ
  FPages[0].StartDrawItemNo := 0;
  FPages[0].EndDrawItemNo := 0;
end;

function THCCustomSection.DeleteSelected: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.DeleteSelected;
    end);
end;

destructor THCCustomSection.Destroy;
begin
  FHeader.Free;
  FFooter.Free;
  FPageData.Free;
  FPageSize.Free;
  FPages.Free;
  inherited Destroy;
end;

procedure THCCustomSection.DisActive;
begin
  //if FActiveData <> nil then
    FActiveData.DisSelect;

  FHeader.InitializeField;
  FFooter.InitializeField;
  FPageData.InitializeField;
  FActiveData := FPageData;
end;

procedure THCCustomSection.DisSelect;
begin
  FActiveData.GetTopLevelData.DisSelect;
end;

procedure THCCustomSection.DoActiveDataCheckUpdateInfo;
begin
  if Assigned(FOnCheckUpdateInfo) then
    FOnCheckUpdateInfo(Self);
end;

procedure THCCustomSection.DoDataChanged(Sender: TObject);
begin
  if Assigned(FOnDataChanged) then
    FOnDataChanged(Sender);
end;

procedure THCCustomSection.DoDataCreateItem(Sender: TObject);
begin
  if Assigned(FOnCreateItem) then
    FOnCreateItem(Sender);
end;

function THCCustomSection.DoDataCreateStyleItem(const AStyleNo: Integer): THCCustomItem;
begin
  if Assigned(FOnCreateItemByStyle) then
    Result := FOnCreateItemByStyle(AStyleNo)
  else
    Result := nil;
end;

procedure THCCustomSection.DoDataDrawItemPaintAfter(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  if Assigned(FOnDrawItemPaintAfter) then
    FOnDrawItemPaintAfter(AData, ADrawItemNo, ADrawRect, ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
end;

procedure THCCustomSection.DoDataInsertItem(const AItem: THCCustomItem);
begin
  if Assigned(FOnInsertItem) then
    FOnInsertItem(AItem);
end;

procedure THCCustomSection.DoDataItemPaintAfter(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  if Assigned(FOnItemPaintAfter) then
  begin
    FOnItemPaintAfter(AData, ADrawItemNo, ADrawRect, ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  end;
end;

procedure THCCustomSection.DoDataItemPaintBefor(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  if Assigned(FOnItemPaintBefor) then
  begin
    FOnItemPaintBefor(AData, ADrawItemNo, ADrawRect, ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  end;
end;

procedure THCCustomSection.DoDataItemResized(const AData: THCCustomData; const AItemNo: Integer);
var
  vData: THCCustomData;
  vResizeItem: THCResizeRectItem;
  vWidth, vHeight: Integer;
begin
  vResizeItem := AData.Items[AItemNo] as THCResizeRectItem;
  vWidth := GetContentWidth;  // ҳ��

  vData := AData.GetRootData;  // ��ȡ����һ���ֵ�ResizeItem
  if vData = FHeader then
    vHeight := GetHeaderAreaHeight
  else
  if vData = FFooter then
    vHeight := FPageSize.PageMarginBottomPix
  else
  if vData = FPageData then
    vHeight := GetContentHeight - FStyle.ParaStyles[vResizeItem.ParaNo].LineSpace;

  vResizeItem.RestrainSize(vWidth, vHeight);

  if Assigned(FOnItemResized) then
    FOnItemResized(AData, AItemNo);
end;

procedure THCCustomSection.DoDataReadOnlySwitch(Sender: TObject);
begin
  if Assigned(FOnReadOnlySwitch) then
    FOnReadOnlySwitch(Self);
end;

function THCCustomSection.DoGetScreenCoordEvent(const X, Y: Integer): TPoint;
begin
  if Assigned(FOnGetScreenCoord) then
    Result := FOnGetScreenCoord(X, Y);
end;

function THCCustomSection.DoDataGetUndoList: THCUndoList;
begin
  if Assigned(FOnGetUndoList) then
    Result := FOnGetUndoList
  else
    Result := nil;
end;

procedure THCCustomSection.SetActiveData(const Value: THCSectionData);
begin
  if FActiveData <> Value then
  begin
    if FActiveData <> nil then
      FActiveData.DisActive;  // �ɵ�ȡ������
    FActiveData := Value;
    FStyle.UpdateInfoReScroll;
  end;
end;

procedure THCCustomSection.FormatData;
begin
  FActiveData.DisSelect;  // ����ѡ�У���ֹ��ʽ����ѡ��λ�ò�����
  FHeader.ReFormat(0);
  Footer.ReFormat(0);
  FPageData.ReFormat(0);
end;

function THCCustomSection.GetCurrentPageIndex: Integer;
var
  i, vCaretDrawItemNo: Integer;
  vCaretInfo: TCaretInfo;
begin
  Result := -1;
  if FActiveData <> FPageData then
    Result := FActivePageIndex
  else
  begin
    if FPageData.CaretDrawItemNo < 0 then
    begin
      vCaretDrawItemNo := FPageData.GetDrawItemNoByOffset(FPageData.SelectInfo.StartItemNo,
        FPageData.SelectInfo.StartItemOffset);
    end
    else
      vCaretDrawItemNo := FPageData.CaretDrawItemNo;

    for i := 0 to FPages.Count - 1 do
    begin
      if FPages[i].EndDrawItemNo >= vCaretDrawItemNo then
      begin
        if (i < FPages.Count - 1)
          and (FPages[i + 1].StartDrawItemNo = vCaretDrawItemNo)
        then  // ��ҳ��
        begin
          if FPageData.SelectInfo.StartItemNo >= 0 then
          begin
            vCaretInfo.Y := 0;
            (FPageData as THCCustomData).GetCaretInfo(FPageData.SelectInfo.StartItemNo,
              FPageData.SelectInfo.StartItemOffset, vCaretInfo);

            Result := GetPageIndexByFmt(vCaretInfo.Y);
          end
          else
            Result := GetPageIndexByDrawItem(vCaretDrawItemNo);
        end
        else
          Result := i;

        Break;
      end;
    end;
  end;
end;

function THCCustomSection.GetActiveArea: TSectionArea;
begin
  if FActiveData = FHeader then
    Result := TSectionArea.saHeader
  else
  if FActiveData = FFooter then
    Result := TSectionArea.saFooter
  else
    Result := TSectionArea.saData;
end;

function THCCustomSection.GetTopLevelDrawItem: THCCustomDrawItem;
begin
  Result := FActiveData.GetTopLevelDrawItem;
end;

function THCCustomSection.GetActiveDrawItemCoord: TPoint;
begin
  Result := FActiveData.GetActiveDrawItemCoord;
end;

function THCCustomSection.GetTopLevelItem: THCCustomItem;
begin
  Result := FActiveData.GetTopLevelItem;
end;

function THCCustomSection.GetContentHeight: Integer;
begin
  Result := FPageSize.PageHeightPix  // ��ҳ����������߶ȣ���ҳ���ҳü��ҳ�ź󾻸�
    - FPageSize.PageMarginBottomPix - GetHeaderAreaHeight;
end;

function THCCustomSection.GetContentWidth: Integer;
begin
  Result := FPageSize.PageWidthPix - FPageSize.PageMarginLeftPix - FPageSize.PageMarginRightPix;
end;

function THCCustomSection.GetCurItem: THCCustomItem;
begin
  FActiveData.GetCurItem;
end;

function THCCustomSection.GetReadOnly: Boolean;
begin
  Result := FHeader.ReadOnly and FFooter.ReadOnly and FPageData.ReadOnly;
end;

function THCCustomSection.GetSectionDataAt(const X, Y: Integer): THCSectionData;
var
  vPageIndex, vMarginLeft, vMarginRight: Integer;
begin
  Result := nil;
  vPageIndex := GetPageIndexByFilm(Y);
  GetPageMarginLeftAndRight(vPageIndex, vMarginLeft, vMarginRight);
  // ȷ�����ҳ����ʾ����
  if X < 0 then  // ����ҳ��ߵ�MinPadding����TEditArea.eaLeftPad
  begin
    Result := FActiveData;
    Exit;
  end;

  if X > FPageSize.PageWidthPix then  // ����ҳ�ұߵ�MinPadding����TEditArea.eaRightPad
  begin
    Result := FActiveData;
    Exit;
  end;

  if Y < 0 then  // ����ҳ�ϱߵ�MinPadding����TEditArea.eaTopPad
  begin
    Result := FActiveData;
    Exit;
  end;

  if Y > FPageSize.PageHeightPix then  // ֻ�������һҳ�±ߵ�MinPadding������ʱ����TEditArea.eaBottomPad
  begin
    Result := FActiveData;
    Exit;
  end;

  // �߾���Ϣ�������£�������
  if Y > FPageSize.PageHeightPix - FPageSize.PageMarginBottomPix then  // �����ҳ�±߾�����TEditArea.eaMarginBottom
    Exit(FFooter);

  // ҳü����ʵ�ʸ�(ҳü���ݸ߶�>�ϱ߾�ʱ��ȡҳü���ݸ߶�)
  if Y < GetHeaderAreaHeight then  // �����ҳü/�ϱ߾�����TEditArea.eaMarginTop
    Exit(FHeader);

  //if X > FPageSize.PageWidthPix - vMarginRight then Exit;  // �����ҳ�ұ߾�����TEditArea.eaMarginRight
  //if X < vMarginLeft then Exit;  // �����ҳ��߾�����TEditArea.eaMarginLeft
  //���Ҫ�������ұ߾಻�����ģ�ע��˫�����ж�ActiveDataΪnil
  Result := FPageData;
end;

function THCCustomSection.GetDataFmtTopFilm(const AVertical: Integer): Integer;
var
  i, vTop, vContentHeight: Integer;
begin
  Result := 0;
  vTop := 0;
  vContentHeight := GetContentHeight;
  for i := 0 to FPages.Count - 1 do
  begin
    vTop := vTop + vContentHeight;
    if vTop >= AVertical then
    begin
      vTop := AVertical - (vTop - vContentHeight);
      Break;
    end
    else
      Result := Result + PagePadding + FPageSize.PageHeightPix;
  end;
  Result := Result + PagePadding + GetHeaderAreaHeight + vTop;
end;

function THCCustomSection.GetFilmHeight: Cardinal;
begin
  Result := FPages.Count * (PagePadding + FPageSize.PageHeightPix);
end;

function THCCustomSection.GetFilmWidth: Cardinal;
begin
  Result := FPages.Count * (PagePadding + FPageSize.PageWidthPix);
end;

function THCCustomSection.GetHeaderAreaHeight: Integer;
begin
  Result := FHeaderOffset + FHeader.Height;
  if Result < FPageSize.PageMarginTopPix then
    Result := FPageSize.PageMarginTopPix;
  //Result := Result + 20;  // debug
end;

function THCCustomSection.GetHeaderPageDrawTop: Integer;
var
  vHeaderHeight: Integer;
begin
  Result := FHeaderOffset;
  vHeaderHeight := FHeader.Height;
  if vHeaderHeight < (FPageSize.PageMarginTopPix - FHeaderOffset) then
    Result := Result + (FPageSize.PageMarginTopPix - FHeaderOffset - vHeaderHeight) div 2;
end;

function THCCustomSection.GetHint: string;
begin
  //Result := '';
  //if FActiveData <> nil then
    Result := FActiveData.GetTopLevelData.GetHint;
end;

function THCCustomSection.GetPageIndexByFmt(const AVOffset: Integer): Integer;
var
  vContentHeight: Integer;
begin
  vContentHeight := GetContentHeight;
  Result := AVOffset div vContentHeight;
end;

function THCCustomSection.GetPageIndexByDrawItem(const ADrawItemNo: Integer): Integer;
var
  i: Integer;
begin
  // ȡADrawItemNo��ʼλ������ҳ��û�п���ADrawItemNo��ҳ��������Ҫ���ǿɲο�TSection.BuildSectionPages
  Result := 0;
  if ADrawItemNo < 0 then Exit;
  Result := FPages.Count - 1;
  for i := 0 to FPages.Count - 1 do
  begin
    if FPages[i].EndDrawItemNo >= ADrawItemNo then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function THCCustomSection.GetPageIndexByFilm(const AVOffset: Integer): Integer;
var
  i, vPos: Integer;
begin
  Result := -1;
  vPos := 0;
  for i := 0 to FPages.Count - 1 do
  begin
    vPos := vPos + PagePadding + FPageSize.PageHeightPix;
    if vPos >= AVOffset then  // AVOffset < 0ʱ��2�ֿ��ܣ�1��ǰ�ڵ�һҳǰ���Padding��2����һ����
    begin
      Result := i;
      Break;
    end;
  end;

  if (Result < 0) and (AVOffset > vPos) then  // ͬ�����һҳ���棬����һҳ����
    Result := FPages.Count - 1;

  Assert(Result >= 0, 'û�л�ȡ����ȷ��ҳ��ţ�');
end;

procedure THCCustomSection.GetPageCaretInfo(var ACaretInfo: TCaretInfo);
var
  vMarginLeft, vMarginRight, vPageIndex: Integer;
begin
  if FStyle.UpdateInfo.Draging then
    vPageIndex := FMousePageIndex
  else
    vPageIndex := FActivePageIndex;

  if (FActiveData.SelectInfo.StartItemNo < 0) or (vPageIndex < 0) then
  begin
    ACaretInfo.Visible := False;
    Exit;
  end;

  ACaretInfo.PageIndex := vPageIndex;  // ����������ڵ�ҳ
  FActiveData.GetCaretInfoCur(ACaretInfo);

  if ACaretInfo.Visible then  // ������ʾ
  begin
    if FActiveData = FPageData then  // ҳ��䶯����Ҫ�жϹ�괦����ҳ
    begin
      vMarginLeft := GetPageIndexByFmt(ACaretInfo.Y);  // ���ñ���vMarginLeft��ʾҳ���
      if vPageIndex <> vMarginLeft then  // �����һ��һ���ֿ�ҳʱ�������һҳͬ�������ݵĵ�Ԫ����ص���һҳ
      begin
        vPageIndex := vMarginLeft;
        FActivePageIndex := vPageIndex;
      end;
    end;

    GetPageMarginLeftAndRight(vPageIndex, vMarginLeft, vMarginRight);
    ACaretInfo.X := ACaretInfo.X + vMarginLeft;
    ACaretInfo.Y := ACaretInfo.Y + GetPageTopFilm(vPageIndex);

    if FActiveData = FHeader then
      ACaretInfo.Y := ACaretInfo.Y + GetHeaderPageDrawTop  // ҳ�ڽ��е�Topλ��
    else
    if FActiveData = FPageData then
      ACaretInfo.Y := ACaretInfo.Y + GetHeaderAreaHeight - GetPageDataFmtTop(vPageIndex)  // - ҳ��ʼ������Data�е�λ��
    else
    if FActiveData = FFooter then
      ACaretInfo.Y := ACaretInfo.Y + FPageSize.PageHeightPix - FPageSize.PageMarginBottomPix;
  end;
end;

function THCCustomSection.GetPageCount: Integer;
begin
  Result := FPages.Count;  // ����ҳ��
end;

function THCCustomSection.GetPageDataFmtTop(const APageIndex: Integer): Integer;
var
  i, vContentHeight: Integer;
begin
  Result := 0;
  if APageIndex > 0 then
  begin
    vContentHeight := GetContentHeight;

    for i := 0 to APageIndex - 1 do
      Result := Result + vContentHeight;
  end;
end;

function THCCustomSection.GetPageHeightPix: Integer;
begin
  Result := FPageSize.PageHeightPix;
end;

function THCCustomSection.GetPageMarginBottomPix: Integer;
begin
  Result := FPageSize.PageMarginBottomPix;
end;

function THCCustomSection.GetPageMarginLeft(const APageIndex: Integer): Integer;
var
  vMarginRight: Integer;
begin
  GetPageMarginLeftAndRight(APageIndex, Result, vMarginRight);
end;

procedure THCCustomSection.GetPageMarginLeftAndRight(const APageIndex: Integer;
  var AMarginLeft, AMarginRight: Integer);
begin
  if FSymmetryMargin and Odd(APageIndex) then
  begin
    AMarginLeft := FPageSize.PageMarginRightPix;
    AMarginRight := FPageSize.PageMarginLeftPix;
  end
  else
  begin
    AMarginLeft := FPageSize.PageMarginLeftPix;
    AMarginRight := FPageSize.PageMarginRightPix;
  end;
end;

function THCCustomSection.GetPageMarginLeftPix: Integer;
begin
  Result := FPageSize.PageMarginLeftPix;
end;

function THCCustomSection.GetPageMarginRightPix: Integer;
begin
  Result := FPageSize.PageMarginRightPix;
end;

function THCCustomSection.GetPageMarginTopPix: Integer;
begin
  Result := FPageSize.PageMarginTopPix;
end;

function THCCustomSection.GetPageTopFilm(const APageIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := PagePadding;
  for i := 0 to APageIndex - 1 do
    Result := Result + FPageSize.PageHeightPix + PagePadding;  // ÿһҳ��������ķָ���Ϊһ����������Ԫ
end;

function THCCustomSection.GetPageWidthPix: Integer;
begin
  Result := FPageSize.PageWidthPix;
end;

function THCCustomSection.GetPaperHeight: Single;
begin
  Result := FPageSize.PaperHeight;
end;

function THCCustomSection.GetPaperMarginBottom: Single;
begin
  Result := FPageSize.PaperMarginBottom;
end;

function THCCustomSection.GetPaperMarginLeft: Single;
begin
  Result := FPageSize.PaperMarginLeft;
end;

function THCCustomSection.GetPaperMarginRight: Single;
begin
  Result := FPageSize.PaperMarginRight;
end;

function THCCustomSection.GetPaperMarginTop: Single;
begin
  Result := FPageSize.PaperMarginTop;
end;

function THCCustomSection.GetPaperSize: Integer;
begin
  Result := FPageSize.PaperSize;
end;

function THCCustomSection.GetPaperWidth: Single;
begin
  Result := FPageSize.PaperWidth;
end;

function THCCustomSection.InsertAnnotate(const AText: string): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FPageData.InsertAnnotate(AText);
    end);
end;

function THCCustomSection.InsertBreak: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FPageData.InsertBreak;
    end);
end;

function THCCustomSection.InsertItem(const AIndex: Integer;
  const AItem: THCCustomItem): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertItem(AIndex, AItem);
    end);
end;

function THCCustomSection.InsertItem(const AItem: THCCustomItem): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertItem(AItem);
    end);
end;

function THCCustomSection.InsertLine(const ALineHeight: Integer): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertLine(ALineHeight);
    end);
end;

function THCCustomSection.InsertPageBreak: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FPageData.InsertPageBreak;
    end);
end;

function THCCustomSection.ActiveDataChangeByAction(const AFunction: THCFunction): Boolean;
var
  vHeight, vDrawItemCount, vCurItemNo, vNewItemNo: Integer;
begin
  if not FActiveData.CanEdit then Exit(False);

  // ��¼�䶯ǰ��״̬
  vHeight := FActiveData.Height;
  // Ӧ��ѡ���ı���ʽ�Ȳ�������������߶ȱ仯����������DrawItem�����仯
  // Ҳ��Ҫ���¼����ҳ��ʼ����DrawItem
  vDrawItemCount := FActiveData.DrawItems.Count;  // �䶯ǰ��DrawItem����
  vCurItemNo := FActiveData.GetCurItemNo;

  Result := AFunction;  // �����䶯

  // �䶯���״̬
  vNewItemNo := FActiveData.GetCurItemNo;  // �䶯��ĵ�ǰItemNo
  if vNewItemNo < 0 then  // ����䶯��С��0������Ϊ��0��
    vNewItemNo := 0;

  if (vDrawItemCount <> FActiveData.DrawItems.Count)  // DrawItem�����仯��
    or (vHeight <> FActiveData.Height)  // ���ݸ߶ȱ仯��
  then
  begin
    if FActiveData = FPageData then
      BuildSectionPages(Min(Min(vCurItemNo, vNewItemNo), FPageData.ReFormatStartItemNo))
    else
      BuildSectionPages(0);
  end;

  DoDataChanged(Self);
end;

function THCCustomSection.InsertStream(const AStream: TStream; const AStyle: THCStyle;
  const AFileVersion: Word): Boolean;
var
  vResult: Boolean;
begin
  Result := False;
  ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertStream(AStream, AStyle, AFileVersion);
      vResult := Result;
    end);
  Result := vResult;
end;

function THCCustomSection.InsertTable(const ARowCount, AColCount: Integer): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertTable(ARowCount, AColCount);
    end);
end;

function THCCustomSection.InsertText(const AText: string): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertText(AText);
    end);
end;

procedure THCCustomSection.KeyDown(var Key: Word; Shift: TShiftState);
var
  vKey: Word;
begin
  if not FActiveData.CanEdit then Exit;

  if IsKeyDownWant(Key) then
  begin
    vKey := Key;
    case Key of
      VK_BACK, VK_DELETE, VK_RETURN, VK_TAB:
        begin
          ActiveDataChangeByAction(function(): Boolean
            begin
              FActiveData.KeyDown(vKey, Shift);
            end);

          Key := vKey;
        end;

      VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END:
        begin
          FActiveData.KeyDown(Key, Shift);
          FActivePageIndex := GetCurrentPageIndex;  // ����������ƶ���������ҳ
          DoActiveDataCheckUpdateInfo;
        end;
    end;
  end;
end;

procedure THCCustomSection.KeyPress(var Key: Char);
var
  vKey: Char;
begin
  if not FActiveData.CanEdit then Exit;

  if IsKeyPressWant(Key) then
  begin
    vKey := Key;
    ActiveDataChangeByAction(function(): Boolean
      begin
        FActiveData.KeyPress(vKey);
      end);
    Key := vKey;
  end
  else
    Key := #0;
end;

procedure THCCustomSection.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if not FActiveData.CanEdit then Exit;
  FActiveData.KeyUp(Key, Shift);
end;

procedure THCCustomSection.KillFocus;
begin
  //if FActiveData <> nil then
    FActiveData.KillFocus;
end;

procedure THCCustomSection.LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
  const AFileVersion: Word);
var
  vDataSize: Int64;
  vArea: Boolean;
  vLoadParts: TSaveParts;
begin
  AStream.ReadBuffer(vDataSize, SizeOf(vDataSize));

  AStream.ReadBuffer(FSymmetryMargin, SizeOf(FSymmetryMargin));  // �Ƿ�Գ�ҳ�߾�

  if AFileVersion > 11 then
  begin
    AStream.ReadBuffer(FPageOrientation, SizeOf(FPageOrientation));  // ֽ�ŷ���
    AStream.ReadBuffer(FPageNoVisible, SizeOf(FPageNoVisible));  // �Ƿ���ʾҳ��
  end;

  FPageSize.LoadToStream(AStream, AFileVersion);  // ҳ�����
  FPageData.Width := GetContentWidth;

  // �ĵ�������Щ����������
  vLoadParts := [];
  AStream.ReadBuffer(vArea, SizeOf(vArea));
  if vArea then
    vLoadParts := vLoadParts + [saHeader];
  AStream.ReadBuffer(vArea, SizeOf(vArea));
  if vArea then
    vLoadParts := vLoadParts + [saFooter];
  AStream.ReadBuffer(vArea, SizeOf(vArea));
  if vArea then
    vLoadParts := vLoadParts + [saData];

  if saHeader in vLoadParts then
  begin
    AStream.ReadBuffer(FHeaderOffset, SizeOf(FHeaderOffset));
    FHeader.Width := FPageData.Width;
    FHeader.LoadFromStream(AStream, FStyle, AFileVersion);
  end;

  if saFooter in vLoadParts then
  begin
    FFooter.Width := FPageData.Width;
    FFooter.LoadFromStream(AStream, FStyle, AFileVersion);
  end;

  if saData in vLoadParts then
    FPageData.LoadFromStream(AStream, FStyle, AFileVersion);

  BuildSectionPages(0);
end;

procedure THCCustomSection.LoadFromText(const AFileName: string;
  const AEncoding: TEncoding);
begin
  FPageData.LoadFromText(AFileName, AEncoding);
  BuildSectionPages(0);
end;

procedure THCCustomSection.MarkStyleUsed(const AMark: Boolean;
  const AParts: TSaveParts = [saHeader, saData, saFooter]);
begin
  if saHeader in AParts then
    FHeader.MarkStyleUsed(AMark);

  if saFooter in AParts then
    FFooter.MarkStyleUsed(AMark);

  if saData in AParts then
    FPageData.MarkStyleUsed(AMark);
end;

function THCCustomSection.MergeTableSelectCells: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.MergeTableSelectCells;
    end);
end;

procedure THCCustomSection.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vX, vY, vPageIndex, vFloatItemIndex: Integer;
  vNewActiveData: THCSectionData;
  vChangeActiveData: Boolean;
begin
  vChangeActiveData := False;

  vPageIndex := GetPageIndexByFilm(Y);  // ����������ڵ�ҳ(�͹������ҳ���ܲ�����ͬһҳ��������ҳʱ���յ�Ԫ��ڶ�ҳ���ʱ������ǰһҳ)
  if FActivePageIndex <> vPageIndex then
    FActivePageIndex := vPageIndex;

  SectionCoordToPage(FActivePageIndex, X, Y, vX, vY);  // X��Yת����ָ��ҳ������vX,vY

  vNewActiveData := GetSectionDataAt(vX, vY);

  if (vNewActiveData <> FActiveData) and (ssDouble in Shift) then  // ˫�����µ�Data
  begin
    SetActiveData(vNewActiveData);
    vChangeActiveData := True;
  end;

  PageCoordToData(FActivePageIndex, FActiveData, vX, vY, False);

  if FActiveData = FPageData then
    vY := vY + GetPageDataFmtTop(FActivePageIndex);

  if (ssDouble in Shift) and (not vChangeActiveData) then  // ��ͬһData��˫��
    FActiveData.DblClick(vX, vY)
  else
    FActiveData.MouseDown(Button, Shift, vX, vY);
end;

procedure THCCustomSection.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vMarginLeft, vMarginRight: Integer;
  vX, vY: Integer;
  vMoveData: THCSectionData;
begin
  // Ĭ�Ϲ��
  GetPageMarginLeftAndRight(FMousePageIndex, vMarginLeft, vMarginRight);

  if X < vMarginLeft then
    GCursor := crDefault  { to do: �����ϽǼ�ͷ }
  else
  if X > FPageSize.PageWidthPix - vMarginRight then
    GCursor := crDefault
  else
    GCursor := crIBeam;

  FMousePageIndex := GetPageIndexByFilm(Y);
  if FMousePageIndex < 0 then Exit;

  SectionCoordToPage(FMousePageIndex, X, Y, vX, vY);

  //if Shift <> [] then  // �в���ʱ�жϣ����ڵ�ǰ����Data��ʱ������(�������ҳ�滮ѡ��ҳ��ʱ���ټ�����ѡ�н���λ��)
  vMoveData := GetSectionDataAt(vX, vY);
  if (vMoveData <> FActiveData) and (Shift = []) then
  begin
    FActiveData.MouseLeave;
    //if not (FActiveData.GetTopLevelData.GetActiveItem is THCResizeRectItem) then
    Exit;  // ���ڵ�ǰ�����Data���ƶ�
  end;

  PageCoordToData(FMousePageIndex, FActiveData, vX, vY, not FActiveData.SelectedResizing);

  if FActiveData = FPageData then
    vY := vY + GetPageDataFmtTop(FMousePageIndex);

  FActiveData.MouseMove(Shift, vX, vY);
end;

procedure THCCustomSection.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vX, vY, vPageIndex: Integer;
begin
  vPageIndex := GetPageIndexByFilm(Y);
  SectionCoordToPage(vPageIndex, X, Y, vX, vY);

  //if GetRichDataAt(vX, vY) <> FActiveData then Exit;  // ���ڵ�ǰ�����Data��

  PageCoordToData(vPageIndex, FActiveData, vX, vY);
  if FActiveData = FPageData then
    vY := vY + GetPageDataFmtTop(vPageIndex);

  // RectItem��������MouseUp�д�����������Ҫ�ж��Ƿ���Ҫ�ı�
  if FActiveData.SelectedResizing then
  begin
    ActiveDataChangeByAction(function(): Boolean
      begin
        FActiveData.MouseUp(Button, Shift, vX, vY);
      end);
  end
  else
    FActiveData.MouseUp(Button, Shift, vX, vY);
end;

function THCCustomSection.NewEmptyPage: THCPage;
begin
  Result := THCPage.Create;
  FPages.Add(Result);
end;

procedure THCCustomSection.PageCoordToData(const APageIndex: Integer;
  const AData: THCRichData; var AX, AY: Integer; const ARestrain: Boolean = False);
var
  viTemp, vMarginLeft, vMarginRight: Integer;
begin
  GetPageMarginLeftAndRight(APageIndex, vMarginLeft, vMarginRight);
  AX := AX - vMarginLeft;
  if ARestrain then  // Ϊ�������ұ߽磬������Լ��1�������޷��㵽���׹�꣬������������RectItem
  begin
    if AX < 0 then
      AX := 0
    else
    begin
      viTemp := FPageSize.PageWidthPix - vMarginLeft - vMarginRight;
      if AX > viTemp then
        AX := viTemp;
    end;
  end;

  // Ϊ����߽�(�������ģ���ҳüҳ�ŵ��ʱ�ж�����������λ����ɹ�����)Լ����ƫ��1
  if AData = FHeader then
  begin
    AY := AY - GetHeaderPageDrawTop;
    if ARestrain then  // Լ����ҳü����������
    begin
      if AY < FHeaderOffset then
        AY := FHeaderOffset + 1
      else
      begin
        viTemp := GetHeaderAreaHeight;
        if AY > viTemp then
          AY := viTemp - 1;
      end;
    end;
  end
  else
  if AData = FFooter then  // Լ����ҳ�ž���������
  begin
    AY := AY - FPageSize.PageHeightPix + FPageSize.PageMarginBottomPix;
    if ARestrain then
    begin
      if AY < 0 then
        AY := 1
      else
      if AY > FPageSize.PageMarginBottomPix then
        AY := FPageSize.PageMarginBottomPix - 1;
    end;
  end
  else
  if AData = FPageData then  // Լ�������ľ���������
  begin
    viTemp := GetHeaderAreaHeight;
    AY := AY - GetHeaderAreaHeight;
    if ARestrain then  // Ϊ������һҳ����һҳü�߽粻ȷ�����ϻ����£�Լ����ƫ��1
    begin
      if AY < 0 then
        AY := 1  // �����������ģ���ҳüҳ���е��
      else
      begin
        viTemp := FPageSize.PageHeightPix - GetHeaderAreaHeight - FPageSize.PageMarginBottomPix;
        if AY > viTemp then
          AY := viTemp - 1;
      end;
    end;
  end;
end;

procedure THCCustomSection.PaintDisplayPage(const AFilmOffsetX, AFilmOffsetY: Integer;
  const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
var
  i, vPageDrawTop, vPageFilmTop: Integer;
begin
  //vPageDrawLeft := AFilmOffsetX;
  //vHeaderAreaHeight := GetHeaderAreaHeight;  // ҳü����ʵ�ʸ�(���ݸ߶�>�ϱ߾�ʱȡ���ݸ߶�)
  for i := FDisplayFirstPageIndex to FDisplayLastPageIndex do
  begin
    APaintInfo.PageIndex := i;
    vPageFilmTop := GetPageTopFilm(i);
    vPageDrawTop := vPageFilmTop - AFilmOffsetY;  // ӳ�䵽��ǰҳ��Ϊԭ���������ʼλ��(��Ϊ����)
    PaintPage(i, AFilmOffsetX, vPageDrawTop, ACanvas, APaintInfo);
  end;
end;

procedure THCCustomSection.PaintPage(const APageIndex, ALeft, ATop: Integer;
  const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
var
  vHeaderAreaHeight, vMarginLeft, vMarginRight,
  vPageDrawLeft, vPageDrawRight, vPageDrawTop, vPageDrawBottom,  // ҳ�����λ��
  vPageDataScreenTop, vPageDataScreenBottom,  // ҳ������Ļλ��
  vScaleWidth, vScaleHeight: Integer;

  {$REGION 'ҳü'}
  procedure PaintHeader;
  var
    vHeaderDataDrawTop, vHeaderDataDrawBottom, vDCState: Integer;
  begin
    vHeaderDataDrawTop := vPageDrawTop + GetHeaderPageDrawTop;
    vHeaderDataDrawBottom := vPageDrawTop + vHeaderAreaHeight;

    FHeader.PaintData(vPageDrawLeft + vMarginLeft, vHeaderDataDrawTop,
      vHeaderDataDrawBottom, Max(vHeaderDataDrawTop, 0),
      Min(vHeaderDataDrawBottom, APaintInfo.WindowHeight), 0, ACanvas, APaintInfo);

    if FActiveData = FHeader then  // ��ǰ�������ҳü
    begin
      ACanvas.Pen.Color := clBlue;
      ACanvas.MoveTo(vPageDrawLeft, vHeaderDataDrawBottom - 1);
      ACanvas.LineTo(vPageDrawRight, vHeaderDataDrawBottom - 1);
    end;

    if Assigned(FOnPaintHeader) then
    begin
      vDCState := Windows.SaveDC(ACanvas.Handle);
      try
        FOnPaintHeader(Self, APageIndex, Rect(vPageDrawLeft + vMarginLeft, vHeaderDataDrawTop,
          vPageDrawRight - vMarginRight, vHeaderDataDrawBottom), ACanvas, APaintInfo);
      finally
        Windows.RestoreDC(ACanvas.Handle, vDCState);
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'ҳ��'}
  procedure PaintFooter;
  var
    vY, vDCState: Integer;
    vS: string;
  begin
    vY := vPageDrawBottom - FPageSize.PageMarginBottomPix;
    FFooter.PaintData(vPageDrawLeft + vMarginLeft, vY, vPageDrawBottom,
      Max(vY, 0), Min(vPageDrawBottom, APaintInfo.WindowHeight), 0, ACanvas, APaintInfo);

    if FActiveData = FFooter then  // ��ǰ�������ҳ��
    begin
      ACanvas.Pen.Color := clBlue;
      ACanvas.MoveTo(vPageDrawLeft, vY);
      ACanvas.LineTo(vPageDrawRight, vY);
    end;

    if Assigned(FOnPaintFooter) then
    begin
      vDCState := Windows.SaveDC(ACanvas.Handle);
      try
        FOnPaintFooter(Self, APageIndex, Rect(vPageDrawLeft + vMarginLeft, vY,
          vPageDrawRight - vMarginRight, vPageDrawBottom), ACanvas, APaintInfo);
      finally
        Windows.RestoreDC(ACanvas.Handle, vDCState);
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION '����ҳ������'}
  procedure PaintPageData;
  var
    vPageDataFmtTop, vDCState: Integer;
  begin
    if (FPages[APageIndex].StartDrawItemNo < 0) or (FPages[APageIndex].EndDrawItemNo < 0) then
      Exit;

    //vPageDataOffsetX := Max(AFilmOffsetX - vPageDrawLeft - PageMarginLeftPix, 0);
    { ��ǰҳ�ڵ�ǰ���Գ��������ݱ߽�ӳ�䵽��ʽ���еı߽� }
    vPageDataFmtTop := GetPageDataFmtTop(APageIndex);

    { �������ݣ���Data��ָ��λ�õ����ݣ����Ƶ�ָ����ҳ�����У������տ���ʾ����������Լ�� }
    FPageData.PaintData(vPageDrawLeft + vMarginLeft,  // ��ǰҳ����Ҫ���Ƶ���Left
      vPageDrawTop + vHeaderAreaHeight,     // ��ǰҳ����Ҫ���Ƶ���Top
      vPageDrawBottom - PageMarginBottomPix,  // ��ǰҳ����Ҫ���Ƶ�Bottom
      vPageDataScreenTop,     // ������ֵ�ǰҳ���ݵ�Topλ��
      vPageDataScreenBottom,  // ������ֵ�ǰҳ����Bottomλ��
      vPageDataFmtTop,  // ָ�����ĸ�λ�ÿ�ʼ�����ݻ��Ƶ�ҳ������ʼλ��
      ACanvas,
      APaintInfo);

    if Assigned(FOnPaintPage) then
    begin
      vDCState := Windows.SaveDC(ACanvas.Handle);
      try
        FOnPaintPage(Self, APageIndex, Rect(vPageDrawLeft + vMarginLeft,
          vPageDrawTop + vHeaderAreaHeight, vPageDrawRight - vMarginRight,
          vPageDrawBottom - PageMarginBottomPix), ACanvas, APaintInfo);
      finally
        Windows.RestoreDC(ACanvas.Handle, vDCState);
      end;
    end;
  end;
  {$ENDREGION}

var
  vX, vY: Integer;
  vPaintRegion: HRGN;
  vClipBoxRect: TRect;
begin
  vScaleWidth := Round(APaintInfo.WindowWidth / APaintInfo.ScaleX);
  vScaleHeight := Round(APaintInfo.WindowHeight / APaintInfo.ScaleY);

  vPageDrawLeft := ALeft;
  vPageDrawRight := vPageDrawLeft + FPageSize.PageWidthPix;

  vHeaderAreaHeight := GetHeaderAreaHeight;  // ҳü����ʵ�ʸ� = ҳü���ݶ���ƫ�� + ���ݸ߶ȣ������ϱ߾�ʱ�Դ�Ϊ׼
  GetPageMarginLeftAndRight(APageIndex, vMarginLeft, vMarginRight);  // ��ȡҳ���ұ߾����λ��

  vPageDrawTop := ATop;  // ӳ�䵽��ǰҳ�����Ͻ�Ϊԭ�����ʼλ��(��Ϊ����)
  vPageDrawBottom := vPageDrawTop + FPageSize.PageHeightPix;  // ҳ�����λ��(��Ϊ����)
  // ��ǰҳ��������ʾ����������߽�
  vPageDataScreenTop := Max(vPageDrawTop + vHeaderAreaHeight, 0);
  vPageDataScreenBottom := Min(vPageDrawBottom - FPageSize.PageMarginBottomPix, vScaleHeight);

  APaintInfo.PageDrawRight := vPageDrawRight;

  GetClipBox(ACanvas.Handle, vClipBoxRect);  // ���浱ǰ�Ļ�ͼ����

  if not APaintInfo.Print then  // �Ǵ�ӡʱ���Ƶ�����
  begin

    {$REGION ' �Ǵ�ӡʱ���ҳ�汳�� '}
    ACanvas.Brush.Color := FStyle.BackgroudColor;
    ACanvas.FillRect(Rect(vPageDrawLeft, vPageDrawTop,
      Min(vPageDrawRight, vScaleWidth),  // Լ���߽�
      Min(vPageDrawBottom, vScaleHeight)));
    {$ENDREGION}

    {$REGION ' ҳü�߾�ָʾ�� '}
    if vPageDrawTop + vHeaderAreaHeight > 0 then  // ҳü����ʾ
    begin
      vY := vPageDrawTop + vHeaderAreaHeight;
      if vHeaderAreaHeight > FPageSize.PageMarginTopPix then  // ҳü���ݳ���ҳ�ϱ߾�
      begin
        ACanvas.Pen.Style := TPenStyle.psDot;
        ACanvas.Pen.Color := clGray;
        APaintInfo.DrawNoScaleLine(ACanvas, [Point(vPageDrawLeft, vY - 1),
          Point(vPageDrawRight, vY - 1)]);
      end;

      ACanvas.Pen.Width := 1;
      ACanvas.Pen.Color := clGray;
      ACanvas.Pen.Style := TPenStyle.psSolid;

      // ���ϣ� ��-ԭ-��
      vX := vPageDrawLeft + vMarginLeft;
      vY := vPageDrawTop + FPageSize.PageMarginTopPix;
      APaintInfo.DrawNoScaleLine(ACanvas, [Point(vX - PMSLineHeight, vY),
        Point(vX, vY), Point(vX, vY - PMSLineHeight)]);
      // ���ϣ���-ԭ-��
      vX := vPageDrawLeft + FPageSize.PageWidthPix - vMarginRight;
      APaintInfo.DrawNoScaleLine(ACanvas, [Point(vX + PMSLineHeight, vY),
        Point(vX, vY), Point(vX, vY - PMSLineHeight)]);
    end;
    {$ENDREGION}

    {$REGION ' ҳ�ű߾�ָʾ�� '}
    vY := vPageDrawBottom - FPageSize.PageMarginBottomPix;
    if vY < APaintInfo.WindowHeight then  // ҳ�ſ���ʾ
    begin
      ACanvas.Pen.Width := 1;
      ACanvas.Pen.Color := clGray;
      ACanvas.Pen.Style := TPenStyle.psSolid;

      // ���£���-ԭ-��
      vX := vPageDrawLeft + vMarginLeft;
      ACanvas.MoveTo(vX - PMSLineHeight, vY);
      ACanvas.LineTo(vX, vY);
      ACanvas.LineTo(vX, vY + PMSLineHeight);
      // ���£���-ԭ-��
      vX := vPageDrawRight - vMarginRight;
      ACanvas.MoveTo(vX + PMSLineHeight, vY);
      ACanvas.LineTo(vX, vY);
      ACanvas.LineTo(vX, vY + PMSLineHeight);
    end;
    {$ENDREGION}

  end;

  {$REGION ' ����ҳü '}
  if vPageDrawTop + vHeaderAreaHeight > 0 then  // ҳü����ʾ
  begin
    vPaintRegion := CreateRectRgn(APaintInfo.GetScaleX(vPageDrawLeft),
      Max(APaintInfo.GetScaleY(vPageDrawTop + FHeaderOffset), 0),
      APaintInfo.GetScaleX(vPageDrawRight),
      Min(APaintInfo.GetScaleY(vPageDrawTop + vHeaderAreaHeight), APaintInfo.WindowHeight));

    try
      //ACanvas.Brush.Color := clYellow;
      //FillRgn(ACanvas.Handle, vPaintRegion, ACanvas.Brush.Handle);
      SelectClipRgn(ACanvas.Handle, vPaintRegion);  // ���û�����Ч����
      PaintHeader;
    finally
      DeleteObject(vPaintRegion);
    end;

    {ACanvas.Brush.Color := clInfoBk;
    vRect := Rect(vPageDrawLeft, Max(vPageDrawTop + FHeaderOffset, 0),
    vPageDrawRight,
    Min(vPageDrawTop + vHeaderAreaHeight, vScaleHeight));
    ACanvas.FillRect(vRect);}

  end;
  {$ENDREGION}

  {$REGION ' ����ҳ�� '}
  if APaintInfo.GetScaleY(vPageDrawBottom - FPageSize.PageMarginBottomPix) < APaintInfo.WindowHeight then  // ҳ�ſ���ʾ
  begin
    vPaintRegion := CreateRectRgn(APaintInfo.GetScaleX(vPageDrawLeft),
      Max(APaintInfo.GetScaleY(vPageDrawBottom - FPageSize.PageMarginBottomPix), 0),
      APaintInfo.GetScaleX(vPageDrawRight),
      Min(APaintInfo.GetScaleY(vPageDrawBottom), APaintInfo.WindowHeight));

    try
      //ACanvas.Brush.Color := clRed;
      //FillRgn(ACanvas.Handle, vPaintRegion, ACanvas.Brush.Handle);
      SelectClipRgn(ACanvas.Handle, vPaintRegion);  // ���û�����Ч����
      PaintFooter;
    finally
      DeleteObject(vPaintRegion);
    end;

    {ACanvas.Brush.Color := clYellow;
    vRect := Rect(vPageDrawLeft,
      Max(vPageDrawBottom - FPageSize.PageMarginBottomPix, 0),
      vPageDrawRight,
      Min(vPageDrawBottom, vScaleHeight));
    ACanvas.FillRect(vRect);}
  end;
  {$ENDREGION}

  {$REGION ' �������� '}
  if vPageDataScreenBottom > vPageDataScreenTop then  // ��¶����������Ƶ�ǰҳ����������
  begin
    vPaintRegion := CreateRectRgn(APaintInfo.GetScaleX(vPageDrawLeft),
      APaintInfo.GetScaleY(Max(vPageDrawTop + vHeaderAreaHeight, vPageDataScreenTop)),
      APaintInfo.GetScaleX(vPageDrawRight),
      APaintInfo.GetScaleY(Min(vPageDrawBottom - FPageSize.PageMarginBottomPix, vPageDataScreenBottom)));
    try
      SelectClipRgn(ACanvas.Handle, vPaintRegion);  // ���û�����Ч����
      PaintPageData;
    finally
      DeleteObject(vPaintRegion);
    end;

    {ACanvas.Brush.Color := clYellow;
    vRect := Rect(vPageDrawLeft,
      Max(vPageDrawTop + vHeaderAreaHeight, vPageDataScreenTop),
      vPageDrawRight,
      Min(vPageDrawBottom - PageMarginBottomPix, vPageDataScreenBottom));
    ACanvas.FillRect(vRect);}
  end;
  {$ENDREGION}

  // �ָ�����׼������ҳ������
  vPaintRegion := CreateRectRgn(
    APaintInfo.GetScaleX(vClipBoxRect.Left),
    APaintInfo.GetScaleX(vClipBoxRect.Top),
    APaintInfo.GetScaleX(vClipBoxRect.Right),
    APaintInfo.GetScaleX(vClipBoxRect.Bottom));
  try
    SelectClipRgn(ACanvas.Handle, vPaintRegion);
  finally
    DeleteObject(vPaintRegion);
  end;

  if Assigned(FOnPaintWholePage) then  // ����ҳ������¼�
  begin
    FOnPaintWholePage(Self, APageIndex,
      Rect(vPageDrawLeft, vPageDrawTop, vPageDrawRight, vPageDrawBottom),
      ACanvas, APaintInfo);
  end;
end;

procedure THCCustomSection.BuildSectionPages(const AStartItemNo: Integer);
var
  vPageIndex, vPageDataFmtTop, vPageDataFmtBottom, vContentHeight,
  vSuplus,  // ������ҳ����ƫ�������ܺ�
  vBreakSeat  // ��ҳλ�ã���ͬRectItem�ĺ��岻ͬ�������ʾ vBreakRow
    : Integer;

  {$REGION '_FormatNewPage'}
  procedure _FormatNewPage(const APrioEndDItemNo, ANewStartDItemNo: Integer);
  var
    vPage: THCPage;
  begin
    FPages[vPageIndex].EndDrawItemNo := APrioEndDItemNo;
    vPage := THCPage.Create;
    vPage.StartDrawItemNo := ANewStartDItemNo;
    FPages.Insert(vPageIndex + 1, vPage);
    Inc(vPageIndex);
  end;
  {$ENDREGION}

  {$REGION '_FormatRectItemCheckPageBreak'}
  procedure _FormatRectItemCheckPageBreak(const ADrawItemNo: Integer);
  var
    vRectItem: THCCustomRectItem;

    {$REGION '_RectItemCheckPage'}
    procedure _RectItemCheckPage(const AStartSeat: Integer);  // ��ʼ��ҳ�����λ�ã���ͬRectItem���岻ͬ�������ʾAStartRowNo
    var
      vFmtHeightInc, vFmtOffset: Integer;
      vDrawRect: TRect;
    begin
      if FPageData.GetDrawItemStyle(ADrawItemNo) = THCStyle.RsPageBreak then
      begin
        vFmtOffset := vPageDataFmtBottom - FPageData.DrawItems[ADrawItemNo].Rect.Top;

        vSuplus := vSuplus + vFmtOffset;
        if vFmtOffset > 0 then  // ���������ƶ���
          OffsetRect(FPageData.DrawItems[ADrawItemNo].Rect, 0, vFmtOffset);

        vPageDataFmtTop := vPageDataFmtBottom;
        vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;

        _FormatNewPage(ADrawItemNo - 1, ADrawItemNo)  // �½�ҳ
      end
      else
      if FPageData.DrawItems[ADrawItemNo].Rect.Bottom > vPageDataFmtBottom then  // ��ǰҳ�Ų��±�������(���м��)
      begin
        if (FPages[vPageIndex].StartDrawItemNo = ADrawItemNo)
          and (AStartSeat = 0)
          and (not vRectItem.CanPageBreak)
        then  // ��ǰҳ��ͷ��ʼ��ҳ�Ų��£�Ҳ�������ضϣ�ǿ�Ʊ䰫��ǰҳ����ʾ������ʾ����
        begin
          vFmtHeightInc := vPageDataFmtBottom - FPageData.DrawItems[ADrawItemNo].Rect.Bottom;
          vSuplus := vSuplus + vFmtHeightInc;
          FPageData.DrawItems[ADrawItemNo].Rect.Bottom :=  // �����ʽ���߶�
            FPageData.DrawItems[ADrawItemNo].Rect.Bottom + vFmtHeightInc;
          vRectItem.Height := vRectItem.Height + vFmtHeightInc;  // �������ﴦ���ػ�����RectItem�ڲ������ʣ�

          Exit;
        end;

        vDrawRect := FPageData.DrawItems[ADrawItemNo].Rect;

        if vSuplus = 0 then  // ��һ�μ����ҳ
          InflateRect(vDrawRect, 0, -FStyle.ParaStyles[vRectItem.ParaNo].LineSpaceHalf);  // �����м��

        vRectItem.CheckFormatPageBreak(  // ȥ���м����жϱ����ҳλ��
          FPages.Count - 1,
          vDrawRect.Top,  // ����Ķ���λ�� FPageData.DrawItems[ADrawItemNo].Rect.Top,
          vDrawRect.Bottom,  // ����ĵײ�λ�� FPageData.DrawItems[ADrawItemNo].Rect.Bottom,
          vPageDataFmtTop,
          vPageDataFmtBottom,  // ��ǰҳ�����ݵײ�λ��
          AStartSeat,  // ��ʼλ��
          vBreakSeat,  // ��ǰҳ��ҳ����(λ��)
          vFmtOffset,  // ��ǰRectItemΪ�˱ܿ���ҳλ����������ƫ�Ƶĸ߶�
          vFmtHeightInc  // ��ǰ�и���Ϊ�˱ܿ���ҳλ�õ�Ԫ�����ݶ���ƫ�Ƶ����߶�
          );

        if vBreakSeat < 0 then // ��ȥ�м����ÿ�ҳ�Ϳ�����ʾ��
        begin
          vSuplus := vSuplus + vPageDataFmtBottom - vDrawRect.Bottom;
        end
        else  // vBreakSeat >= 0 ��vBreakSeatλ�ÿ�ҳ
        if vFmtOffset > 0 then  // �����ҳ�����������ƶ���
        begin
          vFmtOffset := vFmtOffset + FStyle.ParaStyles[vRectItem.ParaNo].LineSpaceHalf;  // ���������ƶ���������������м��
          vSuplus := vSuplus + vFmtOffset + vFmtHeightInc;

          OffsetRect(FPageData.DrawItems[ADrawItemNo].Rect, 0, vFmtOffset);

          vPageDataFmtTop := vPageDataFmtBottom;
          vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;
          _FormatNewPage(ADrawItemNo - 1, ADrawItemNo);  // �½�ҳ
          _RectItemCheckPage(vBreakSeat);
        end
        else  // ��ҳ����δ��������
        begin
          vSuplus := vSuplus{ + vFmtOffset} + vFmtHeightInc;
          FPageData.DrawItems[ADrawItemNo].Rect.Bottom :=  // �����ʽ���߶�
            FPageData.DrawItems[ADrawItemNo].Rect.Bottom + vFmtHeightInc;
          vRectItem.Height := vRectItem.Height + vFmtHeightInc;  // �������ﴦ���ػ�����RectItem�ڲ������ʣ�

          vPageDataFmtTop := vPageDataFmtBottom;
          vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;
          _FormatNewPage(ADrawItemNo, ADrawItemNo);  // �½�ҳ
          _RectItemCheckPage(vBreakSeat);  // �ӷ�ҳλ�ú����������Ƿ��ҳ
        end;
      end;
    end;
    {$ENDREGION}

  var
    i: Integer;
  begin
    vRectItem := FPageData.Items[FPageData.DrawItems[ADrawItemNo].ItemNo] as THCCustomRectItem;
    vSuplus := 0;
    vBreakSeat := 0;

    vRectItem.CheckFormatPageBreakBefor;
    _RectItemCheckPage(0);  // ���ʼλ�ã���������������Ƿ�����ʾ�ڵ�ǰҳ

    if vSuplus <> 0 then
    begin
      for i := ADrawItemNo + 1 to FPageData.DrawItems.Count - 1 do
        OffsetRect(FPageData.DrawItems[i].Rect, 0, vSuplus);
    end;
  end;
  {$ENDREGION}

  {$REGION '_FormatTextItemCheckPageBreak'}
  procedure _FormatTextItemCheckPageBreak(const ADrawItemNo: Integer);
  var
    i, vH: Integer;
  begin
    //if not DrawItems[ADrawItemNo].LineFirst then Exit; // ע��������ֻ���ʱ����Ͳ���ֻ�ж��е�1��
    if FPageData.DrawItems[ADrawItemNo].Rect.Bottom > vPageDataFmtBottom then
    begin
      vH := vPageDataFmtBottom - FPageData.DrawItems[ADrawItemNo].Rect.Top;
      for i := ADrawItemNo to FPageData.DrawItems.Count - 1 do
        OffsetRect(FPageData.DrawItems[i].Rect, 0, vH);

      vPageDataFmtTop := vPageDataFmtBottom;
      vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;
      _FormatNewPage(ADrawItemNo - 1, ADrawItemNo); // �½�ҳ
    end;
  end;
  {$ENDREGION}

var
  i, vPrioDrawItemNo: Integer;
  vPage: THCPage;
begin
  if AStartItemNo > 0 then
    vPrioDrawItemNo := FPageData.GetItemLastDrawItemNo(AStartItemNo - 1)  // ��һ������DItem
  else
    vPrioDrawItemNo := -1;

  // ��һ��DrawItemNo����ҳ��Ϊ��ʽ����ʼҳ
  vPageIndex := -1;
  if vPrioDrawItemNo < 0 then  // û��DrawItem����0ҳ
    vPageIndex := 0
  else  // ָ����DrawItemNo
  begin
    for i := FPages.Count - 1 downto 0 do  // ���ڿ�ҳ�ģ������λ������ҳ�����Ե���
    begin
      vPage := FPages[i];
      if (vPrioDrawItemNo >= vPage.StartDrawItemNo)
        and (vPrioDrawItemNo <= vPage.EndDrawItemNo)
      then  // ��Ϊ�����п�ҳ��������Ҫ�ж���ʼ����������
      begin
        vPageIndex := i;
        Break;
      end;
    end;
  end;

  // ��Ϊ���׿����Ƿ�ҳ��������Ҫ�����׿�ʼ�жϿ�ҳ
  for i := FPageData.Items[AStartItemNo].FirstDItemNo downto 0 do
  begin
    if FPageData.DrawItems[i].LineFirst then
    begin
      vPrioDrawItemNo := i;
      Break;
    end;
  end;

  if vPrioDrawItemNo = FPages[vPageIndex].StartDrawItemNo then  // ������ҳ�ĵ�һ��DrawItem
  begin
    FPages.DeleteRange(vPageIndex, FPages.Count - vPageIndex);  // ɾ����ǰҳһֱ�����

    // ����һҳ���ʼ�����ҳ
    Dec(vPageIndex);
    if vPageIndex >= 0 then
      FPages[vPageIndex].EndDrawItemNo := -1;
  end
  else  // ���ײ���ҳ�ĵ�һ��DrawItem
    FPages.DeleteRange(vPageIndex + 1, FPages.Count - vPageIndex - 1);  // ɾ����ǰҳ����ģ�׼����ʽ��

  if FPages.Count = 0 then  // ɾ��û�ˣ������һ��Page
  begin
    vPage := THCPage.Create;
    vPage.StartDrawItemNo := vPrioDrawItemNo;
    FPages.Add(vPage);
    vPageIndex := 0;
  end;

  vPageDataFmtTop := GetPageDataFmtTop(vPageIndex);
  vContentHeight := GetContentHeight;
  vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;

  for i := vPrioDrawItemNo to FPageData.DrawItems.Count - 1 do
  begin
    if FPageData.DrawItems[i].LineFirst then
    begin
      if FPageData.Items[FPageData.DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then
        _FormatRectItemCheckPageBreak(i)
      else
        _FormatTextItemCheckPageBreak(i);
    end;
  end;

  FPages[vPageIndex].EndDrawItemNo := FPageData.DrawItems.Count - 1;
  FActivePageIndex := GetCurrentPageIndex;
end;

procedure THCCustomSection.Redo(const ARedo: THCUndo);
begin
  if FActiveData <> ARedo.Data then
    SetActiveData(ARedo.Data as THCSectionData);

  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.Redo(ARedo);
    end);
end;

procedure THCCustomSection.ReFormatActiveItem;
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ReFormatActiveItem;
    end);
end;

procedure THCCustomSection.ResetMargin;
begin
  FPageData.Width := GetContentWidth;

  FHeader.Width := FPageData.Width;
  FFooter.Width := FPageData.Width;

  FormatData;

  BuildSectionPages(0);

  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret(False);

  DoDataChanged(Self);
end;

procedure THCCustomSection.SaveToStream(const AStream: TStream;
  const ASaveParts: TSaveParts = [saHeader, saData, saFooter]);
var
  vBegPos, vEndPos: Int64;
  vArea: Boolean;
begin
  vBegPos := AStream.Position;
  AStream.WriteBuffer(vBegPos, SizeOf(vBegPos));  // ���ݴ�Сռλ������Խ��
  //
  if ASaveParts <> [] then
  begin
    AStream.WriteBuffer(FSymmetryMargin, SizeOf(FSymmetryMargin));  // �Ƿ�Գ�ҳ�߾�

    AStream.WriteBuffer(FPageOrientation, SizeOf(FPageOrientation));  // ֽ�ŷ���
    AStream.WriteBuffer(FPageNoVisible, SizeOf(FPageNoVisible));  // �Ƿ���ʾҳ��

    FPageSize.SaveToStream(AStream);  // ҳ�����

    vArea := saHeader in ASaveParts;  // ��ҳü
    AStream.WriteBuffer(vArea, SizeOf(vArea));

    vArea := saFooter in ASaveParts;  // ��ҳ��
    AStream.WriteBuffer(vArea, SizeOf(vArea));

    vArea := saData in ASaveParts;  // ��ҳ��
    AStream.WriteBuffer(vArea, SizeOf(vArea));

    if saHeader in ASaveParts then  // ��ҳü
    begin
      AStream.WriteBuffer(FHeaderOffset, SizeOf(FHeaderOffset));
      FHeader.SaveToStream(AStream);
    end;

    if saFooter in ASaveParts then  // ��ҳ��
      FFooter.SaveToStream(AStream);

    if saData in ASaveParts then  // ��ҳ��
      FPageData.SaveToStream(AStream);
  end;
  //
  vEndPos := AStream.Position;
  AStream.Position := vBegPos;
  vBegPos := vEndPos - vBegPos - SizeOf(vBegPos);
  AStream.WriteBuffer(vBegPos, SizeOf(vBegPos));  // ��ǰ�����ݴ�С
  AStream.Position := vEndPos;
end;

procedure THCCustomSection.SectionCoordToPage(const APageIndex, X, Y: Integer; var APageX,
  APageY: Integer);
var
  vPageFilmTop{, vMarginLeft, vMarginRight}: Integer;
begin
  // Ԥ��ҳ�����Ű�ʱ����
  //GetPageMarginLeftAndRight(APageIndex, vMarginLeft, vMarginRight);
  APageX := X;// - vMarginLeft;

  vPageFilmTop := GetPageTopFilm(APageIndex);
  APageY := Y - vPageFilmTop;  // ӳ�䵽��ǰҳ��Ϊԭ���������ʼλ��(��Ϊ����)
end;

procedure THCCustomSection.SelectAll;
begin
  FActiveData.SelectAll;
end;

function THCCustomSection.SelectExists: Boolean;
begin
  //Result := False;
  //if FActiveData <> nil then
    Result := FActiveData.SelectExists
end;

procedure THCCustomSection.SetHeaderOffset(const Value: Integer);
begin
  if FHeaderOffset <> Value then
  begin
    FHeaderOffset := Value;
    BuildSectionPages(0);
    DoDataChanged(Self);
  end;
end;

procedure THCCustomSection.SetPageHeightPix(const Value: Integer);
begin
  if FPageSize.PageHeightPix <> Value then
    FPageSize.PageHeightPix := Value;
end;

procedure THCCustomSection.SetPageMarginBottomPix(const Value: Integer);
begin
  if FPageSize.PageMarginBottomPix <> Value then
    FPageSize.PageMarginBottomPix := Value;
end;

procedure THCCustomSection.SetPageMarginLeftPix(const Value: Integer);
begin
  if FPageSize.PageMarginLeftPix <> Value then
    FPageSize.PageMarginLeftPix := Value;
end;

procedure THCCustomSection.SetPageMarginRightPix(const Value: Integer);
begin
  if FPageSize.PageMarginRightPix <> Value then
    FPageSize.PageMarginRightPix := Value;
end;

procedure THCCustomSection.SetPageMarginTopPix(const Value: Integer);
begin
  if FPageSize.PageMarginTopPix <> Value then
    FPageSize.PageMarginTopPix := Value;
end;

procedure THCCustomSection.SetPageOrientation(const Value: TPageOrientation);
var
  vfW: Single;
begin
  if FPageOrientation <> Value then
  begin
    FPageOrientation := Value;

    vfW := FPageSize.PaperWidth;
    FPageSize.PaperWidth := FPageSize.PaperHeight;
    FPageSize.PaperHeight := vfW;
  end;
end;

procedure THCCustomSection.SetPageWidthPix(const Value: Integer);
begin
  if FPageSize.PageWidthPix <> Value then
    FPageSize.PageWidthPix := Value;
end;

procedure THCCustomSection.SetPaperHeight(const Value: Single);
begin
  FPageSize.PaperHeight := Value;
  FPageSize.PaperSize := DMPAPER_USER;
end;

procedure THCCustomSection.SetPaperMarginBottom(const Value: Single);
begin
  FPageSize.PaperMarginBottom := Value;
end;

procedure THCCustomSection.SetPaperMarginLeft(const Value: Single);
begin
  FPageSize.PaperMarginLeft := Value;
end;

procedure THCCustomSection.SetPaperMarginRight(const Value: Single);
begin
  FPageSize.PaperMarginRight := Value;
end;

procedure THCCustomSection.SetPaperMarginTop(const Value: Single);
begin
  FPageSize.PaperMarginTop := Value;
end;

procedure THCCustomSection.SetPaperSize(const Value: Integer);
begin
  FPageSize.PaperSize := Value;
end;

procedure THCCustomSection.SetPaperWidth(const Value: Single);
begin
  FPageSize.PaperWidth := Value;
  FPageSize.PaperSize := DMPAPER_USER;
end;

procedure THCCustomSection.SetReadOnly(const Value: Boolean);
begin
  FHeader.ReadOnly := Value;
  FFooter.ReadOnly := Value;
  FPageData.ReadOnly := Value;
end;

procedure THCCustomSection.Undo(const AUndo: THCUndo);
begin
  if FActiveData <> AUndo.Data then
    SetActiveData(AUndo.Data as THCSectionData);

  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.Undo(AUndo);
    end);
end;

end.