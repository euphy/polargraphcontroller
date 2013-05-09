/**
  Polargraph controller
  Copyright Sandy Noble 2012.

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
  http://code.google.com/p/polargraph/
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
  cp5.tab(TAB_NAME_INPUT).setLabel(TAB_LABEL_INPUT);
  cp5.tab(TAB_NAME_INPUT).activateEvent(true);
  cp5.tab(TAB_NAME_INPUT).setId(1);

  cp5.tab(TAB_NAME_DETAILS).setLabel(TAB_LABEL_DETAILS);
  cp5.tab(TAB_NAME_DETAILS).activateEvent(true);
  cp5.tab(TAB_NAME_DETAILS).setId(2);

  cp5.tab(TAB_NAME_ROVING).setLabel(TAB_LABEL_ROVING);
  cp5.tab(TAB_NAME_ROVING).activateEvent(true);
  cp5.tab(TAB_NAME_ROVING).setId(3);

  cp5.tab(TAB_NAME_TRACE).setLabel(TAB_LABEL_TRACE);
  cp5.tab(TAB_NAME_TRACE).activateEvent(true);
  cp5.tab(TAB_NAME_TRACE).setId(4);

  cp5.tab(TAB_NAME_QUEUE).setLabel(TAB_LABEL_QUEUE);
  cp5.tab(TAB_NAME_QUEUE).activateEvent(true);
  cp5.tab(TAB_NAME_QUEUE).setId(5);
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

