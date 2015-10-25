/**
  Polargraph controller
  Copyright Sandy Noble 2015.

  This file is part of Polargraph Controller.

  Polargraph Controller is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Polargraph Controller is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Polargraph Controller.  If not, see <http://www.gnu.org/licenses/>.
    
  Requires the excellent ControlP5 GUI library available from http://www.sojamo.de/libraries/controlP5/.
  Requires the excellent Geomerative library available from http://www.ricardmarxer.com/geomerative/.
  
  This is an application for controlling a polargraph machine, communicating using ASCII command language over a serial link.

  sandy.noble@gmail.com
  http://www.polargraph.co.uk/
  https://github.com/euphy/polargraphcontroller
*/

Set<Panel> getPanelsForTab(String tabName)
{
  if (getPanelsForTabs().containsKey(tabName))
  {
    return getPanelsForTabs().get(tabName);
  }
  else
    return new HashSet<Panel>(0);
}

Map<String, Set<Panel>> buildPanelsForTabs()
{
  Map<String, Set<Panel>> map = new HashMap<String, Set<Panel>>();

  Set<Panel> inputPanels = new HashSet<Panel>(2);
  inputPanels.add(getPanel(PANEL_NAME_INPUT));
  inputPanels.add(getPanel(PANEL_NAME_GENERAL));

  Set<Panel> rovingPanels = new HashSet<Panel>(2);
  rovingPanels.add(getPanel(PANEL_NAME_ROVING));
  rovingPanels.add(getPanel(PANEL_NAME_GENERAL));

  Set<Panel> tracePanels = new HashSet<Panel>(2);
  tracePanels.add(getPanel(PANEL_NAME_TRACE));
  tracePanels.add(getPanel(PANEL_NAME_GENERAL));

  Set<Panel> detailsPanels = new HashSet<Panel>(2);
  detailsPanels.add(getPanel(PANEL_NAME_DETAILS));
  detailsPanels.add(getPanel(PANEL_NAME_GENERAL));

  Set<Panel> queuePanels = new HashSet<Panel>(2);
  queuePanels.add(getPanel(PANEL_NAME_QUEUE));
  queuePanels.add(getPanel(PANEL_NAME_GENERAL));
  
  map.put(TAB_NAME_INPUT, inputPanels);
  map.put(TAB_NAME_ROVING, rovingPanels);
  map.put(TAB_NAME_TRACE, tracePanels);
  map.put(TAB_NAME_DETAILS, detailsPanels);
  map.put(TAB_NAME_QUEUE, queuePanels);
  
  return map;
}

List<String> buildTabNames()
{
  List<String> list = new ArrayList<String>(5);
  list.add(TAB_NAME_INPUT);
  list.add(TAB_NAME_ROVING);
  list.add(TAB_NAME_TRACE);
  list.add(TAB_NAME_DETAILS);
  list.add(TAB_NAME_QUEUE);
  return list;
}

void initTabs()
{
  int tabWidth = (int)DEFAULT_CONTROL_SIZE.x;
  int tabHeight = (int)DEFAULT_CONTROL_SIZE.y;
  
  Tab.padding = 13; // that's a weird thing to do
  
  Tab input = cp5.getTab(TAB_NAME_INPUT); 
  input.setLabel(TAB_LABEL_INPUT);
  input.activateEvent(true);
  input.setId(1);

  Tab details = cp5.getTab(TAB_NAME_DETAILS); 
  details.setLabel(TAB_LABEL_DETAILS);
  details.activateEvent(true);
  details.setId(2);
  
  Tab roving = cp5.getTab(TAB_NAME_ROVING);
  roving.setLabel(TAB_LABEL_ROVING);
  roving.activateEvent(true);
  roving.setId(3);

  Tab trace = cp5.getTab(TAB_NAME_TRACE);
  trace.setLabel(TAB_LABEL_TRACE);
  trace.activateEvent(true);
  trace.setId(4);

  Tab queue = cp5.getTab(TAB_NAME_QUEUE);
  queue.setLabel(TAB_LABEL_QUEUE);
  queue.activateEvent(true);
  queue.setId(5);
}

public Set<String> buildPanelNames()
{
  Set<String> set = new HashSet<String>(6);
  set.add(PANEL_NAME_INPUT);
  set.add(PANEL_NAME_ROVING);
  set.add(PANEL_NAME_TRACE);
  set.add(PANEL_NAME_DETAILS);
  set.add(PANEL_NAME_QUEUE);
  set.add(PANEL_NAME_GENERAL);
  return set;
}

