unit uRhoTrackBar;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Objects, FMX.Graphics;

type
  // Custom type for selecting the thumb appearance.
  // NOTE: tsCircle and tsRectangle MUST stay first (ordinals 0 and 1) so any
  // .fmx files already streamed with the old enum keep loading correctly.
  // New shapes are appended after them.
  TThumbShape = (tsCircle, tsRectangle, tsRoundRect, tsTriangle,
    tsInvertedTriangle, tsDiamond, tsPentagon, tsHexagon, tsStar, tsPointer);

  TRhoTrackBar = class(TControl)
  private
    // The track and thumb are now owner-drawn directly on the canvas
    FVersion : String;
    FThumbWidth: Single;   // logical thumb size
    FThumbHeight: Single;
    FThumbX: Single;       // thumb top-left within this control
    FThumbY: Single;
    FTrackRect: TRectF;    // computed track rectangle (set in Resize)
    FTrackColor: TAlphaColor;
    FMin: Single;
    FMax: Single;
    FValue: Single;
    FTickFrequency: Single;
    FShowTicks: Boolean;
    FShowlabels : Boolean;
    FIsDragging: Boolean;
    FLiveTracking: Boolean;

    FOnChange: TNotifyEvent;
    FOnTracking: TNotifyEvent; // New event field tracking pointer

    FOrientation: TOrientation;
    FThumbShape: TThumbShape; // Variable to store current shape selection
    FThumbCornerRadius: Single;
    FThumbFillColor: TAlphaColor;
    FThumbStrokeColor: TAlphaColor;
    FThumbStrokeThickness : Single;
    FTickColor: TAlphaColor;  // Stores tick line color
    FLabelColor: TAlphaColor; // Stores value text label color
    FLabelFontSize: Single;

    FValueSuffix: string; // Storage variable for the suffix

    procedure SetMin(const Value: Single);
    procedure SetMax(const Value: Single);
    procedure SetValue(const Value: Single);
    procedure SetTickFrequency(const Value: Single);
    procedure SetShowTicks(const Value: Boolean);
    procedure SetShowLabels(const Value: Boolean);
    procedure SetOrientation(const Value: TOrientation);
    procedure SetValueSuffix(const Value: string); // Setter declaration
    procedure SetThumbShape(const Value: TThumbShape); // Setter for shape change
    procedure SetThumbHeight(const Value: Single); // New setter
    procedure SetThumbWidth(const Value: Single); // New setter
    procedure SetThumbCornerRadius(const Value: Single);
    procedure SetThumbFillColor(const Value: TAlphaColor);
    procedure SetThumbStrokeColor(const Value: TAlphaColor);
    procedure SetThumbStrokeThickness (const Value : Single);
    procedure SetTickColor(const Value: TAlphaColor);
    procedure SetTrackColor(const Value: TAlphaColor);
    procedure SetLabelColor(const Value: TAlphaColor);
    procedure SetFontSize(const Value: Single);

    function  GetThumbHeight: Single;
    function  GetThumbWidth: Single;
    procedure UpdateThumbPosition;
    procedure CalculateValueFromCoords(X, Y: Single);
    procedure DrawTickMarks;
    procedure DrawTrack;
    procedure DrawThumb;

    procedure ReadStrokeThickness(Reader: TReader);
    procedure WriteStrokeThickness(Writer: TWriter);
    procedure ReadCornerRadius(Reader: TReader);
    procedure WriteCornerRadius(Writer: TWriter);
  protected
    procedure Loaded; override;
    procedure Resize; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Paint; override; // Overriding Paint handles lightning-fast canvas drawing
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DragMode default TDragMode.dmManual;
    property Height;
    property Width;
    property PopupMenu;
    property Margins;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Opacity;
    property Size;
    property Visible;
    property Enabled;
    property Hint;
    property ShowHint;
    property Padding;
    property TouchTargetExpansion;

    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;

    property OnClick;
    property OnDblClick;

    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property OnResize;
    property OnResized;
    property OnPaint;
    property OnPainting;

    property Version: string read FVersion write FVersion stored True;
    property Min: Single read FMin write SetMin;
    property Max: Single read FMax write SetMax;
    property Value: Single read FValue write SetValue;
    property LiveTracking: Boolean read FLiveTracking write FLiveTracking default True;
    property TickFrequency: Single read FTickFrequency write SetTickFrequency;
    property ShowTicks: Boolean read FShowTicks write SetShowTicks;
    property ShowLabels: Boolean read FShowLabels write SetShowLabels;
    property Orientation: TOrientation read FOrientation write SetOrientation;
    property ValueSuffix: string read FValueSuffix write SetValueSuffix; // Published property
    property ThumbShape: TThumbShape read FThumbShape write SetThumbShape; // Published shape control
    property ThumbHeight: Single read GetThumbHeight write SetThumbHeight; // Published property
    property ThumbWidth: Single read GetThumbWidth write SetThumbWidth; // Published property
    property ThumbCornerRadius: Single read FThumbCornerRadius write SetThumbCornerRadius;
    property ThumbFillColor: TAlphaColor read FThumbFillColor write SetThumbFillColor;
    property ThumbStrokeColor: TAlphaColor read FThumbStrokeColor write SetThumbStrokeColor;
    property ThumbStrokeThickness: Single read FThumbStrokeThickness write SetThumbStrokeThickness stored False;
    property TickColor: TAlphaColor read FTickColor write SetTickColor;
    property TrackColor: TAlphaColor read FTrackColor write SetTrackColor;
    property LabelColor: TAlphaColor read FLabelColor write SetLabelColor;
    property LabelFontSize: Single read FLabelFontSize write SetFontSize;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnTracking: TNotifyEvent read FOnTracking write FOnTracking; // Published event hook
  end;

procedure Register;

implementation

Uses Math;

procedure Register;
begin
  RegisterComponents('Rhody Controls', [TRhoTrackBar]);
end;

constructor TRhoTrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FVersion := '1.0.0.0';

  // Default bounds for horizontal setup
  Width := 150;
  Height := 45;
  FMin := 0;
  FMax := 100;
  FValue := 0;
  FTickFrequency := 10;
  FShowTicks := True;
  FOrientation := TOrientation.Horizontal;
  FIsDragging := False;
  FLiveTracking := True;
  FShowLabels := True;
  FLabelFontSize := 10;

  FTickColor := $80808080;  // Soft, translucent dark gray
  FLabelColor := $FF555555; // Muted dark gray text

  FThumbFillColor := $FF007AFF;
  FThumbStrokeColor := $FFFFFFFF;

  FThumbStrokeThickness := 2;

  FThumbShape := TThumbShape.tsCircle; // Circle by default
  FThumbCornerRadius := 4;

  FTrackColor := $FFD3D3D3; // Light gray channel

  FThumbWidth := 16;
  FThumbHeight := 16;

  FValueSuffix := ''; // Empty by default

  Resize;
end;

procedure TRhoTrackBar.ReadStrokeThickness(Reader: TReader);
begin
  FThumbStrokeThickness := Reader.ReadFloat;
end;

procedure TRhoTrackBar.WriteStrokeThickness(Writer: TWriter);
begin
  Writer.WriteFloat(FThumbStrokeThickness);
end;

procedure TRhoTrackBar.ReadCornerRadius(Reader: TReader);
begin
  FThumbCornerRadius := Reader.ReadFloat;
end;

procedure TRhoTrackBar.WriteCornerRadius(Writer: TWriter);
begin
  Writer.WriteFloat(FThumbCornerRadius);
end;

procedure TRhoTrackBar.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('ThumbStrokeThicknessValue', ReadStrokeThickness, WriteStrokeThickness, True);
  Filer.DefineProperty('ThumbCornerRadiusValue', ReadCornerRadius, WriteCornerRadius, True);
end;

procedure TRhoTrackBar.Loaded;
begin
  inherited Loaded;
  // The form has loaded! Now calculate positions using the true layout bounds.
  Resize;
end;

function TRhoTrackBar.GetThumbHeight: Single;
begin
  Result := FThumbHeight;
end;

function TRhoTrackBar.GetThumbWidth: Single;
begin
  Result := FThumbWidth;
end;

// --- Geometry helpers for the path-based thumb -----------------------------
// Vertices are placed on a circle of radius ARadius about ACenter. AStartAngle
// is in radians; -Pi/2 puts the first vertex at the top (12 o'clock).

procedure AddRegularPolygonPath(const APath: TPathData; const ACenter: TPointF;
  const ARadius: Single; const ASides: Integer; const AStartAngle: Single);
var
  I: Integer;
  A: Single;
  P: TPointF;
begin
  for I := 0 to ASides - 1 do
  begin
    A := AStartAngle + I * (2 * Pi / ASides);
    P := PointF(ACenter.X + ARadius * Cos(A), ACenter.Y + ARadius * Sin(A));
    if I = 0 then APath.MoveTo(P) else APath.LineTo(P);
  end;
  APath.ClosePath;
end;

// A star alternates between the outer and inner radius. APoints is the number
// of star points (e.g. 5), so it emits APoints*2 vertices.
procedure AddStarPath(const APath: TPathData; const ACenter: TPointF;
  const AOuter, AInner: Single; const APoints: Integer; const AStartAngle: Single);
var
  I: Integer;
  A, R: Single;
  P: TPointF;
begin
  for I := 0 to (APoints * 2) - 1 do
  begin
    if Odd(I) then R := AInner else R := AOuter;
    A := AStartAngle + I * (Pi / APoints);
    P := PointF(ACenter.X + R * Cos(A), ACenter.Y + R * Sin(A));
    if I = 0 then APath.MoveTo(P) else APath.LineTo(P);
  end;
  APath.ClosePath;
end;

procedure TRhoTrackBar.DrawTrack;
begin
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := FTrackColor;
  Canvas.FillRect(FTrackRect, 4, 4, AllCorners, AbsoluteOpacity);
end;

procedure TRhoTrackBar.DrawThumb;
var
  Path: TPathData;
  Inset: Single;
  R: TRectF;
  C: TPointF;
  Rad: Single;
  PointH: Single;
  Sc: Single;

  // Snap a coordinate to the nearest whole device pixel for the current canvas
  // scale. Without this, under display scaling the fill edge lands on a
  // fractional pixel and antialiases into a faint ring.
  function SnapToPixel(const V: Single): Single;
  begin
    if Sc > 0 then
      Result := Round(V * Sc) / Sc
    else
      Result := V;
  end;

begin
  // Build the shape fresh each paint in ABSOLUTE control coordinates (offset
  // by the thumb's current top-left). Because we draw straight onto this
  // control's canvas, nothing clips the stroke -- the whole outline, including
  // its antialiased edge, is visible.
  Inset := FThumbStrokeThickness / 2;
  R := RectF(FThumbX + Inset,
             FThumbY + Inset,
             FThumbX + FThumbWidth - Inset,
             FThumbY + FThumbHeight - Inset);

  // Align the shape's box to the device pixel grid. This keeps axis-aligned
  // edges crisp under runtime display scaling; otherwise the fill's antialiased
  // edge bleeds the background through as a faint 1px "border" -- visible only
  // when there is no stroke to cover it (i.e. exactly when thickness = 0).
  Sc := Canvas.Scale;
  R := RectF(SnapToPixel(R.Left), SnapToPixel(R.Top),
             SnapToPixel(R.Right), SnapToPixel(R.Bottom));

  C := PointF((R.Left + R.Right) / 2, (R.Top + R.Bottom) / 2);
  // Regular shapes are inscribed in the smaller dimension so they stay
  // symmetric even if the thumb isn't square.
  Rad := Math.Min(R.Width, R.Height) / 2;

  Path := TPathData.Create;
  try
    case FThumbShape of
      tsCircle:
        Path.AddEllipse(R);

      tsRectangle:
        // Honours ThumbCornerRadius (0 => sharp corners), as before.
        Path.AddRectangle(R, FThumbCornerRadius, FThumbCornerRadius,
          AllCorners, TCornerType.Round);

      tsRoundRect:
        // Always visibly rounded (a "pill"), independent of ThumbCornerRadius.
        Path.AddRectangle(R, Math.Max(FThumbCornerRadius, 6),
          Math.Max(FThumbCornerRadius, 6), AllCorners, TCornerType.Round);

      tsTriangle:
        begin
          Path.MoveTo(PointF(C.X, R.Top));
          Path.LineTo(PointF(R.Right, R.Bottom));
          Path.LineTo(PointF(R.Left, R.Bottom));
          Path.ClosePath;
        end;

      tsInvertedTriangle:
        begin
          Path.MoveTo(PointF(R.Left, R.Top));
          Path.LineTo(PointF(R.Right, R.Top));
          Path.LineTo(PointF(C.X, R.Bottom));
          Path.ClosePath;
        end;

      tsDiamond:
        begin
          Path.MoveTo(PointF(C.X, R.Top));
          Path.LineTo(PointF(R.Right, C.Y));
          Path.LineTo(PointF(C.X, R.Bottom));
          Path.LineTo(PointF(R.Left, C.Y));
          Path.ClosePath;
        end;

      tsPentagon:
        AddRegularPolygonPath(Path, C, Rad, 5, -Pi / 2);

      tsHexagon:
        AddRegularPolygonPath(Path, C, Rad, 6, -Pi / 2);

      tsStar:
        AddStarPath(Path, C, Rad, Rad * 0.4, 5, -Pi / 2);

      tsPointer:
        begin
          // A full-width rectangular body with a triangular point rising from
          // the top edge (a "house"/marker pointing up). PointH is how far the
          // peak rises above the shoulders where the roof meets the body.
          PointH := R.Height * 0.4;
          Path.MoveTo(PointF(C.X, R.Top));               // peak
          Path.LineTo(PointF(R.Right, R.Top + PointH));  // right shoulder
          Path.LineTo(PointF(R.Right, R.Bottom));        // bottom-right
          Path.LineTo(PointF(R.Left, R.Bottom));         // bottom-left
          Path.LineTo(PointF(R.Left, R.Top + PointH));   // left shoulder
          Path.ClosePath;
        end;
    end;

    // Fill
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := FThumbFillColor;
    Canvas.FillPath(Path, AbsoluteOpacity);

    // Stroke (border)
    if FThumbStrokeThickness > 0 then
    begin
      Canvas.Stroke.Kind := TBrushKind.Solid;
      Canvas.Stroke.Color := FThumbStrokeColor;
      Canvas.Stroke.Thickness := FThumbStrokeThickness;
      Canvas.DrawPath(Path, AbsoluteOpacity);
    end
  else
     Canvas.Stroke.Thickness := 0;
  finally
    Path.Free;
  end;
end;

procedure TRhoTrackBar.SetThumbShape(const Value: TThumbShape);
begin
  if FThumbShape <> Value then
  begin
    FThumbShape := Value;
    Repaint;
  end;
end;


procedure TRhoTrackBar.SetTickColor(const Value: TAlphaColor);
begin
  if FTickColor <> Value then
  begin
    FTickColor := Value;
    Repaint; // Redraw canvas instantly with the new theme color
  end;
end;

procedure TRhoTrackBar.SetTrackColor(const Value: TAlphaColor);
begin
  if FTrackColor <> Value then
  begin
    FTrackColor := Value;
    Repaint;
  end;
end;

procedure TRhoTrackBar.SetLabelColor(const Value: TAlphaColor);
begin
  if FLabelColor <> Value then
  begin
    FLabelColor := Value;
    Repaint; // Redraw canvas instantly with the new theme color
  end;
end;

procedure TRhoTrackBar.SetFontSize(const Value: Single);
begin
  if FLabelFontSize <> Value then
  begin
    FLabelFontSize := Value;
    Repaint; // Redraw canvas instantly with the new theme color
  end;
end;

procedure TRhoTrackBar.SetThumbCornerRadius(const Value: Single);
begin
  if FThumbCornerRadius <> Value then
  begin
    FThumbCornerRadius := Value;
    Repaint;
  end;
end;

procedure TRhoTrackBar.SetThumbFillColor(const Value: TAlphaColor);
begin
  if FThumbFillColor <> Value then
  begin
    FThumbFillColor := Value;
    Repaint; // Redraw instantly on screen
  end;
end;

procedure TRhoTrackBar.SetThumbStrokeColor(const Value: TAlphaColor);
begin
  if FThumbStrokeColor <> Value then
  begin
    FThumbStrokeColor := Value;
    Repaint;
  end;
end;

procedure TRhoTrackBar.SetThumbStrokeThickness(const Value: Single);
begin
  if FThumbStrokeThickness <> Value then
  begin
    FThumbStrokeThickness := Value;
    Repaint;
  end;
end;


procedure TRhoTrackBar.SetThumbHeight(const Value: Single);
begin
  // Prevent numbers that are too small or negative
  if (FThumbHeight <> Value) and (Value > 2) then
  begin
    FThumbHeight := Value;
    // Rebuild layout geometry (thumb centering, track length) for the new size
    Resize;
  end;
end;

procedure TRhoTrackBar.SetThumbWidth(const Value: Single);
begin
  // Prevent numbers that are too small, negative, or wider than the component itself
  if (FThumbWidth <> Value) and (Value > 2) and (Value < Width) then
  begin
    FThumbWidth := Value;
    // Rebuild layout geometry (thumb centering, track length) for the new size
    Resize;
  end;
end;


procedure TRhoTrackBar.Resize;
const
  TRACK_THICKNESS = 6;
var
  Mid: Single;
begin
  inherited;

  if FOrientation = TOrientation.Horizontal then
  begin
    // Track runs horizontally, centered vertically; its ends are inset by half
    // the thumb so the thumb never overhangs the control at Min/Max.
    Mid := (Height - TRACK_THICKNESS) / 2;
    FTrackRect := RectF(FThumbWidth / 2, Mid,
                        Width - FThumbWidth / 2, Mid + TRACK_THICKNESS);
    // Center the thumb vertically over the channel
    FThumbY := (Height - FThumbHeight) / 2;
  end
  else
  begin
    Mid := (Width - TRACK_THICKNESS) / 2;
    FTrackRect := RectF(Mid, FThumbHeight / 2,
                        Mid + TRACK_THICKNESS, Height - FThumbHeight / 2);
    // Center the thumb horizontally over the channel
    FThumbX := (Width - FThumbWidth) / 2;
  end;

  UpdateThumbPosition;
end;


procedure TRhoTrackBar.Paint;
begin
  inherited;
  DrawTrack;
  if FShowTicks then
    DrawTickMarks;
  DrawThumb; // last, so it sits on top of the track
end;


procedure TRhoTrackBar.DrawTickMarks;
var
  CurrentVal: Single;
  AvailableLength: Single;
  PosOffset: Single;
  StartDim, EndDim: Single;
  ValueStr: string;
  TextRect: TRectF;
  ThumbSize: Single;
begin
  if (FTickFrequency <= 0) or (FMax <= FMin) then Exit;

  CurrentVal := FMin;

  // 1. Dynamic Tick Brush Configuration
  Canvas.Stroke.Color := FTickColor; // Use the property variable here
  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Kind := TBrushKind.Solid;

  // 2. Dynamic Text Brush Configuration
  Canvas.Fill.Color := FLabelColor; // Use the property variable here
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Font.Size := FLabelFontSize;

  if FOrientation = TOrientation.Horizontal then
  begin
    ThumbSize := FThumbWidth;
    AvailableLength := Width - ThumbSize;
    StartDim := FTrackRect.Bottom + 4;
    EndDim := StartDim + 4;

    while CurrentVal <= FMax do
    begin
      PosOffset := (ThumbSize / 2) + (((CurrentVal - FMin) / (FMax - FMin)) * AvailableLength);
      Canvas.DrawLine(TPointF.Create(PosOffset, StartDim), TPointF.Create(PosOffset, EndDim), 1.0);

      if FShowLabels then
         begin
         ValueStr := Format('%.0f', [CurrentVal]) + FValueSuffix;
         TextRect := TRectF.Create(PosOffset - 25, EndDim + 2, PosOffset + 25, EndDim + 16);
         Canvas.FillText(TextRect, ValueStr, False, 1.0, [], TTextAlign.Center, TTextAlign.Center);
         end;

      CurrentVal := CurrentVal + FTickFrequency;
    end;
  end
  else
  begin
    ThumbSize := FThumbHeight;
    AvailableLength := Height - ThumbSize;
    StartDim := FTrackRect.Right + 4;
    EndDim := StartDim + 4;

    while CurrentVal <= FMax do
    begin
      PosOffset := Height - (ThumbSize / 2) - (((CurrentVal - FMin) / (FMax - FMin)) * AvailableLength);
      Canvas.DrawLine(TPointF.Create(StartDim, PosOffset), TPointF.Create(EndDim, PosOffset), 1.0);

      if FShowLabels then
         begin
         ValueStr := Format('%.0f', [CurrentVal]) + FValueSuffix;
         TextRect := TRectF.Create(EndDim + 4, PosOffset - 8, EndDim + 60, PosOffset + 8);
         Canvas.FillText(TextRect, ValueStr, False, 1.0, [], TTextAlign.Leading, TTextAlign.Center);
         end;

      CurrentVal := CurrentVal + FTickFrequency;
    end;
  end;
end;



procedure TRhoTrackBar.UpdateThumbPosition;
var
  Pct: Single;
  AvailableLength: Single;
begin
  if FMax <= FMin then Exit;
  Pct := (FValue - FMin) / (FMax - FMin);
  Pct := EnsureRange(Pct, 0.0, 1.0);

  if FOrientation = TOrientation.Horizontal then
  begin
    AvailableLength := Width - FThumbWidth;
    FThumbX := Pct * AvailableLength;
  end
  else
  begin
    AvailableLength := Height - FThumbHeight;
    FThumbY := Height - FThumbHeight - (Pct * AvailableLength);
  end;

  Repaint;
end;


procedure TRhoTrackBar.CalculateValueFromCoords(X, Y: Single);
var
  NewValue: Single;
  Pct: Single;
  ThumbSize: Single;
  AvailableLength: Single;
begin
  if FOrientation = TOrientation.Horizontal then
  begin
    ThumbSize := FThumbWidth;
    AvailableLength := Width - ThumbSize;
    if AvailableLength <= 0 then Exit;
    Pct := (X - (ThumbSize / 2)) / AvailableLength;
  end
  else
  begin
    ThumbSize := FThumbHeight;
    AvailableLength := Height - ThumbSize;
    if AvailableLength <= 0 then Exit;
    Pct := (Height - Y - (ThumbSize / 2)) / AvailableLength;
  end;

  Pct := EnsureRange(Pct, 0.0, 1.0);
  NewValue := FMin + Pct * (FMax - FMin);

  NewValue := EnsureRange(NewValue, FMin, FMax);

  if FValue <> NewValue then
  begin
    FValue := NewValue;

    // FIX: Only fire OnChange during a drag if LiveTracking is True
    if FLiveTracking then
    begin
      if Assigned(FOnChange) then FOnChange(Self);
    end;
  end;

  UpdateThumbPosition;
end;



procedure TRhoTrackBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if Button = TMouseButton.mbLeft then
  begin
    FIsDragging := True;
    Root.Captured := Self;
    CalculateValueFromCoords(X, Y);
  end;
end;

procedure TRhoTrackBar.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if FIsDragging then CalculateValueFromCoords(X, Y);
end;



procedure TRhoTrackBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if FIsDragging then
  begin
    FIsDragging := False;
    if Assigned(Root) then
      Root.Captured := nil; // Safely release focus capture

    UpdateThumbPosition;

    // FIX: If LiveTracking was False, fire the final confirmed value right here!
    if not FLiveTracking then
    begin
      if Assigned(FOnChange) then FOnChange(Self);
    end;
  end;
end;


{ Property Setters }

procedure TRhoTrackBar.SetOrientation(const Value: TOrientation);
var
  TempDim: Single;
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;

    // FIX: Only swap dimensions if the developer toggles it in the IDE
    // or manually via code. SKIP it if the FMX streaming engine is loading the form!
    if not (csLoading in ComponentState) then
    begin
      TempDim := Width;
      Width := Height;
      Height := TempDim;
    end;

    Resize;
    Repaint;
  end;
end;


procedure TRhoTrackBar.SetValueSuffix(const Value: string);
begin
  if FValueSuffix <> Value then
  begin
    FValueSuffix := Value;
    Repaint; // Redraw canvas text instantly
  end;
end;

procedure TRhoTrackBar.SetMax(const Value: Single);
begin
  if FMax <> Value then
  begin
    FMax := Value;
    if FValue > FMax then SetValue(FMax);
    Repaint;
    UpdateThumbPosition;
  end;
end;

procedure TRhoTrackBar.SetMin(const Value: Single);
begin
  if FMin <> Value then
  begin
    FMin := Value;
    if FValue < FMin then SetValue(FMin);
    Repaint;
    UpdateThumbPosition;
  end;
end;

procedure TRhoTrackBar.SetValue(const Value: Single);
begin
  if FValue <> Value then
  begin
    FValue := EnsureRange(Value, FMin, FMax);
    UpdateThumbPosition;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TRhoTrackBar.SetTickFrequency(const Value: Single);
begin
  if FTickFrequency <> Value then
  begin
    FTickFrequency := Value;
    Repaint;
  end;
end;

procedure TRhoTrackBar.SetShowTicks(const Value: Boolean);
begin
  if FShowTicks <> Value then
  begin
    FShowTicks := Value;
    Repaint;
  end;
end;


procedure TRhoTrackBar.SetShowLabels(const Value: Boolean);
begin
  if FShowLabels <> Value then
  begin
    FShowLabels := Value;
    Repaint;
  end;
end;
end.
