<%--
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc. All rights reserved.
    @author Matthew Lohbihler
--%>
<%@page import="com.serotonin.m2m2.Common"%>
<%@page import="com.serotonin.m2m2.pointLinks.PointLinkVO"%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<c:set var="NEW_ID"><%= Common.NEW_ID %></c:set>

<tag:page dwr="PointLinksDwr" onload="init">
  <script type="text/javascript">
    dojo.require("dojo.store.Memory");
    dojo.require("dijit.form.FilteringSelect");
    
    var sourcePoints;
    var editingPointLink;
    var sourcePointSelector,targetPointSelector;
    
    function init() {
        PointLinksDwr.init(function(response) {
            sourcePoints = response.sourcePoints;
			
            //Fill in the filtering selects for the points
         	sourcePointSelector = new dijit.form.FilteringSelect({
                store: new dojo.store.Memory({idProperty: 'key', data: response.sourcePoints }),
                searchAttr: "value",                  
                autoComplete: false,
                style: "width: 100%",
                queryExpr: "*\${0}*",
                highlightMatch: "all",
                required: true
            }, "sourcePointId");
         	targetPointSelector = new dijit.form.FilteringSelect({
                store: new dojo.store.Memory({idProperty: 'key', data: response.targetPoints }),
                searchAttr: "value",                  
                autoComplete: false,
                style: "width: 100%",
                highlightMatch: "all",
                queryExpr: "*\${0}*",
                required: true
            }, "targetPointId");

            // Create the list of existing links
            for (var i=0; i<response.pointLinks.length; i++) {
                appendPointLink(response.pointLinks[i].id);
                updatePointLink(response.pointLinks[i]);
            }
            
            <c:if test="${!empty param.plid}">
              showPointLink(${param.plid});
            </c:if>
        });
    }
    
    function showPointLink(plId) {
        if (editingPointLink)
            stopImageFader($("pl"+ editingPointLink.id +"Img"));
        PointLinksDwr.getPointLink(plId, function(pl) {
            if (!pl)
                return;
            
            if (!editingPointLink)
                show("pointLinkDetails");
            editingPointLink = pl;
            
            $set("xid", pl.xid);
            
            if(pl.sourcePointId > 0)
            	sourcePointSelector.set('value',pl.sourcePointId);
            else
            	sourcePointSelector.reset();
            
            if(pl.targetPointId > 0)
           		targetPointSelector.set('value',pl.targetPointId);
            else
            	targetPointSelector.reset();
            
            $set("script", pl.script);
            $set("event", pl.event);
            $set("writeAnnotation", pl.writeAnnotation);
            $set("disabled", pl.disabled);
            
            startImageFader($("pl"+ plId +"Img"));
            display("deletePointLinkImg", plId != ${NEW_ID});
            setUserMessage();
        });
    }
    
    function savePointLink() {
        setUserMessage();
        hideContextualMessages("pointLinkDetails")
        //Since the Filtering Select has issues with the IntStringPair objects
        // we can't use .value directly so we need to confirm there is a value set
        var targetPointId=0,sourcePointId=0;
        if(targetPointSelector.item != null){
        	targetPointId = targetPointSelector.item.key;
        }
        if(sourcePointSelector.item != null){
        	sourcePointId = sourcePointSelector.item.key;
        }
        PointLinksDwr.savePointLink(editingPointLink.id, $get("xid"), 
        		sourcePointId, targetPointId,
                $get("script"), $get("event"), $get("writeAnnotation"), $get("disabled"), function(response) {
            if (response.hasMessages)
                showDwrMessages(response.messages);
            else {
                if (editingPointLink.id == ${NEW_ID}) {
                    stopImageFader($("pl"+ editingPointLink.id +"Img"));
                    editingPointLink.id = response.data.plId;
                    appendPointLink(editingPointLink.id);
                    startImageFader($("pl"+ editingPointLink.id +"Img"));
                    setUserMessage("<fmt:message key="pointLinks.pointLinkAdded"/>");
                    show($("deletePointLinkImg"));
                }
                else
                    setUserMessage("<fmt:message key="pointLinks.pointLinkSaved"/>");
                PointLinksDwr.getPointLink(editingPointLink.id, updatePointLink);
            }
        });
    }
    
    function setUserMessage(message) {
        if (message) {
            show("userMessage");
            $set("userMessage", message);
        }
        else
            hide("userMessage");
    }
    
    function appendPointLink(plId) {
        createFromTemplate("pl_TEMPLATE_", plId, "pointLinksTable");
    }
    
    function updatePointLink(pl) {
        $set("pl"+ pl.id +"Name", getPointName(pl.sourcePointId) +' <tag:img png="bullet_go"/> '+ getPointName(pl.targetPointId));
        setPointLinkImg(pl.disabled, $("pl"+ pl.id +"Img"));
    }
    
    function getPointName(pointId) {
        for (var i=0; i<sourcePoints.length; i++) {
            if (sourcePoints[i].key == pointId)
                return sourcePoints[i].value;
        }
        return null;
    }
    
    function deletePointLink() {
        PointLinksDwr.deletePointLink(editingPointLink.id, function() {
            stopImageFader($("pl"+ editingPointLink.id +"Img"));
            $("pointLinksTable").removeChild($("pl"+ editingPointLink.id));
            hide("pointLinkDetails");
            editingPointLink = null;
        });
    }
    
    function validateScript() {
        PointLinksDwr.validateScript($get("script"), $get("sourcePointId"), $get("targetPointId"),
                function(response) {
            showDwrMessages(response.messages);
        });
    }
    
    function setPointLinkImg(disabled, imgNode) {
        if (disabled)
            updateImg(imgNode, "${modulePath}/web/link_break.png", "<m2m2:translate key="js.disabledPointLink" escapeDQuotes="true"/>", true);
        else
            updateImg(imgNode, "${modulePath}/web/link.png", "<m2m2:translate key="pointLinks.pointLink" escapeDQuotes="true"/>", true);
    }
  </script>
  
  <table>
    <tr>
      <td valign="top">
        <div class="borderDiv">
          <table width="100%">
            <tr>
              <td>
                <span class="smallTitle"><fmt:message key="pointLinks.pointLinks"/></span>
                <tag:help id="pointLinks"/>
              </td>
              <td align="right"><tag:img src="${modulePath}/web/link_add.png" title="common.add" 
                      onclick="showPointLink(${NEW_ID})" id="pl${NEW_ID}Img"/></td>
            </tr>
          </table>
          <table id="pointLinksTable">
            <tbody id="pl_TEMPLATE_" onclick="showPointLink(getMangoId(this))" class="ptr" style="display:none">
              <tr>
                <td><tag:img id="pl_TEMPLATE_Img" src="${modulePath}/web/link.png" title="pointLinks.pointLink"/></td>
                <td class="link" id="pl_TEMPLATE_Name"></td>
              </tr>
            </tbody>
          </table>
        </div>
      </td>
      
      <td valign="top" style="display:none;" id="pointLinkDetails">
        <div class="borderDiv">
          <table width="100%">
            <tr>
              <td><span class="smallTitle"><fmt:message key="pointLinks.details"/></span></td>
              <td align="right">
                <tag:img png="save" onclick="savePointLink();" title="common.save"/>
                <tag:img id="deletePointLinkImg" png="delete" onclick="deletePointLink();" title="common.delete"/>
              </td>
            </tr>
          </table>
          
          <table>
            <tr>
              <td class="formLabelRequired"><fmt:message key="common.xid"/></td>
              <td class="formField"><input type="text" id="xid"/></td>
            </tr>
            
            <tr>
              <td class="formLabelRequired"><fmt:message key="pointLinks.source"/></td>
              <td class="formField"><select id="sourcePointId"></select></td>
            </tr>
            
            <tr>
              <td class="formLabelRequired"><fmt:message key="pointLinks.target"/></td>
              <td class="formField"><select id="targetPointId"></select></td>
            </tr>
            
            <tr>
              <td class="formLabel">
                <fmt:message key="pointLinks.script"/>
                <tag:img png="accept" onclick="validateScript();" title="common.validate"/>
              </td>
              <td class="formField">
                <textarea id="script" rows="10" cols="50"/></textarea>
              </td>
            </tr>
            
            <tr>
              <td class="formLabelRequired"><fmt:message key="pointLinks.event"/></td>
              <td class="formField">
                <select id="event">
                  <option value="<c:out value="<%= PointLinkVO.EVENT_CHANGE %>"/>"><fmt:message key="pointLinks.event.change"/></option>
                  <option value="<c:out value="<%= PointLinkVO.EVENT_UPDATE %>"/>"><fmt:message key="pointLinks.event.update"/></option>
                </select>
              </td>
            </tr>
            
            <tr>
              <td class="formLabel"><fmt:message key="pointLinks.writeAnnotation"/></td>
              <td class="formField"><input type="checkbox" id="writeAnnotation"/></td>
            </tr>
            
            <tr>
              <td class="formLabel"><fmt:message key="common.disabled"/></td>
              <td class="formField"><input type="checkbox" id="disabled"/></td>
            </tr>
          </table>
          
          <table>
            <tr>
              <td colspan="2" id="userMessage" class="formError" style="display:none;"></td>
            </tr>
          </table>
        </div>
      </td>
    </tr>
  </table>
</tag:page>