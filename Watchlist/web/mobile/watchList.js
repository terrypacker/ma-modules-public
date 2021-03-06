/*
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc. All rights reserved.
    @author Matthew Lohbihler
*/
//
// Watchlist
mango.view.initWatchlist = function() {

    mango.view.setPoint = mango.view.watchList.setPoint;

    // Tell the long poll request that we're interested in watchlist data, and register our js handler.
    mango.longPoll.addHandler("mobileWatchlist", function(response) {
	//alert('heeeeeeeeeeere');
    	if (response.watchListStates)
    	    mango.view.watchList.setData(response.watchListStates);
    });
};

mango.view.watchList = {};
mango.view.watchList.reset = function() {
	WatchListDwr.resetWatchListState(mango.longPoll.pollSessionId);
};

mango.view.watchList.setPoint = function(pointId, componentId, value) {
    WatchListDwr.setPoint(pointId, componentId, value, null);
};

mango.view.watchList.setData = function(stateArr) {
    for (var i=0; i<stateArr.length; i++)
        mango.view.watchList.setDataImpl(stateArr[i]);
};
    
mango.view.watchList.setDataImpl = function(state) {
    // Check that the point exists. Ignore if it doesn't.
	//alert('zzzz'+state.chart);
    if (state && $("p"+ state.id)) {
	alert('eee'+state);
        var node;
        if (state.value != null) {
            node = $("p"+ state.id +"Value");
            node.innerHTML = state.value;
            dojo.addClass(node, "viewChangeBkgd");
            setTimeout('mango.view.watchList.safeRemoveClass("'+ node.id +'", "viewChangeBkgd")', 2000);
        }
        
        if (state.time != null) {
            node = $("p"+ state.id +"Time");
            node.innerHTML = state.time;
            dojo.addClass(node, "viewChangeBkgd");
            setTimeout('mango.view.watchList.safeRemoveClass("'+ node.id +'", "viewChangeBkgd")', 2000);
        }
        
        if (state.change != null) {
            show($("p"+ state.id +"ChangeMin"));
            if (!mango.view.setEditing)
                $set("p"+ state.id +"Change", state.change);
        }
        
        if (state.chart != null) {
			alert('pppp'+state.chart);
            show($("p"+ state.id +"ChartMin"));
            $set("p"+ state.id +"Chart", state.chart);
        }
        
        if (state.messages != null)
            $("p"+ state.id +"Messages").innerHTML = state.messages;
        //else
        //    $("p"+ state.id +"Messages").innerHTML = "";
    }
};

mango.view.watchList.safeRemoveClass = function(nodeId, className) {
    var node = $(nodeId);
    if (node)
        dojo.removeClass(node, className);
};
