within FinalProject;
model DistributedBuilding
  "Model for a single building with an inductive load, PV array, and battery"
  parameter Modelica.Units.SI.Energy EMax(min=0, displayUnit="kW.h")
    "Maximum battery capacity" annotation (Evaluate=true, Dialog(group="Battery"));
  parameter Modelica.Units.SI.Power chaRat(min=0)
    "Maximum charging rate" annotation (Evaluate=true, Dialog(group="Battery"));
  parameter Real SOC_start(max=1)
    "Initial State of Charge" annotation (Evaluate=true, Dialog(group="Battery"));
  parameter Real minSOC(min=0,max=1)
    "Minimum allowable charge" annotation (Evaluate=true, Dialog(group="Battery"));
  parameter Real maxSOC(min=0,max=1)
    "Maximum allowable charge" annotation (Evaluate=true, Dialog(group="Battery"));
  parameter Real deadbandFrac(min=0.01,max=0.99)
    "Fraction of charge used to define deadband" annotation (Evaluate=true, Dialog(group="Battery"));
  parameter Modelica.Units.SI.Voltage V_nominal
    "Nominal PV/battery voltage";
  parameter Modelica.Units.SI.Power P_nominal
    "Maximum electrical load";
  parameter Modelica.Units.SI.Area A
    "PV gross surface area" annotation (Evaluate=true, Dialog(group="PV Panel"));
  parameter Modelica.Units.SI.Angle til(displayUnit="deg")
    "PV surface tilt" annotation (Evaluate=true, Dialog(group="PV Panel"));
  parameter Modelica.Units.SI.Angle azi(displayUnit="deg")
    "PV surface azimuth" annotation (Evaluate=true, Dialog(group="PV Panel"));

  Buildings.Electrical.AC.ThreePhasesBalanced.Storage.Battery bat(
    SOC_start=SOC_start,
    EMax=EMax,
    V_nominal=V_nominal)
    annotation (Placement(transformation(extent={{0,-20},{20,0}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive loadRL(mode=
        Buildings.Electrical.Types.Load.VariableZ_y_input, P_nominal=P_nominal)
    annotation (Placement(transformation(extent={{-20,20},{-40,40}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.PVSimpleOriented pv(
    A=A,
    til=til,
    azi=azi,
    V_nominal=V_nominal)
    annotation (Placement(transformation(extent={{0,20},{20,40}})));
  Modelica.Blocks.Interfaces.RealInput loa
    annotation (Placement(transformation(extent={{-130,40},{-90,80}})));
  Modelica.Blocks.Interfaces.RealInput auxP
    annotation (Placement(transformation(extent={{-130,-80},{-90,-40}})));
  Modelica.Blocks.Interfaces.RealOutput pvP
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Modelica.Blocks.Interfaces.RealOutput batSOC
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
  Buildings.BoundaryConditions.WeatherData.Bus
                                     weaBus "Weather data" annotation (
     Placement(transformation(extent={{0,60},{20,80}}),    iconTransformation(
          extent={{-10,80},{10,100}})));
  Modelica.Blocks.Interfaces.RealOutput loadP
    annotation (Placement(transformation(extent={{100,50},{120,70}})));
  Modelica.Blocks.Sources.RealExpression loadPos(y=-loadRL.P)
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_p terminal
    annotation (Placement(transformation(extent={{-114,-10},{-94,10}})));
  BatteryController controller(
    minSOC=minSOC,
    maxSOC=maxSOC,
    chaRat=chaRat,
    deadbandFrac=deadbandFrac)
    annotation (Placement(transformation(extent={{60,0},{40,20}})));
  Modelica.Blocks.Sources.RealExpression reqP(y=pv.P + loadRL.P + auxP)
    annotation (Placement(transformation(extent={{90,4},{70,24}})));
equation
  connect(pv.terminal, bat.terminal) annotation (Line(points={{0,30},{-4,30},{
          -4,-10},{0,-10}}, color={0,120,120}));
  connect(loadRL.terminal, bat.terminal)
    annotation (Line(points={{-20,30},{-4,30},{-4,-10},{0,-10}},
                                                 color={0,120,120}));
  connect(weaBus, pv.weaBus) annotation (Line(
      points={{10,70},{10,39}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(pv.P, pvP) annotation (Line(points={{21,37},{96,37},{96,0},{110,0}},
        color={0,0,127}));
  connect(bat.SOC, batSOC) annotation (Line(points={{21,-4},{96,-4},{96,-60},{
          110,-60}}, color={0,0,127}));
  connect(loa, loadRL.y) annotation (Line(points={{-110,60},{-50,60},{-50,30},{
          -40,30}},             color={0,0,127}));
  connect(loadPos.y, loadP)
    annotation (Line(points={{81,60},{110,60}}, color={0,0,127}));
  connect(terminal, pv.terminal) annotation (Line(points={{-104,0},{-4,0},{-4,
          30},{0,30}},                 color={0,120,120}));
  connect(controller.P, bat.P)
    annotation (Line(points={{39,10},{10,10},{10,0}}, color={0,0,127}));
  connect(reqP.y, controller.loaDif)
    annotation (Line(points={{69,14},{61,14}}, color={0,0,127}));
  connect(bat.SOC,controller.SOC)
    annotation (Line(points={{21,-4},{70,-4},{70,6},{61,6}}, color={0,0,127}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Polygon(
          points={{-40,-40},{-40,40},{0,74},{40,40},{40,-40},{-40,-40}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={175,175,175},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-60,40},{0,74},{60,40},{-60,40}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={162,29,33},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-20,60},{20,40}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-20,54},{20,54}},
          color={0,0,0},
          thickness=1),
        Line(
          points={{-10,60},{-10,40}},
          color={0,0,0},
          thickness=1),
        Line(
          points={{0,60},{0,40}},
          color={0,0,0},
          thickness=1),
        Line(
          points={{10,60},{10,40}},
          color={0,0,0},
          thickness=1),
        Line(
          points={{-20,46},{20,46}},
          color={0,0,0},
          thickness=1),
        Rectangle(
          extent={{-16,22},{14,8}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={0,140,72},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{14,18},{18,12}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-10,22},{-10,8}},
          color={0,0,0},
          thickness=1),
        Line(
          points={{-4,22},{-4,8}},
          color={0,0,0},
          thickness=1),
        Line(
          points={{2,22},{2,8}},
          color={0,0,0},
          thickness=1),
        Line(
          points={{8,22},{8,8}},
          color={0,0,0},
          thickness=1),
        Rectangle(
          extent={{-10,-40},{10,-14}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={162,29,33},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,-28},{8,-32}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-150,-88},{150,-48}},
          textColor={0,0,0},
          textString="%name")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>Model for a single building with solar PV and a battery. </p>
<p>This model has an electrical connector and determines the difference in solar PV generation and electrical load. A battery is used as a secondary source to privide electricity when there is an insuffienct amount of PV generation. </p>
<h4>Limitations</h4>
<p>There are no thermal loads considered in this model. </p>
<h4>Validation</h4>
<p>The model has been verified in the example, but not validated.
</html>"));
end DistributedBuilding;
