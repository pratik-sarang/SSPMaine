({
    createLineGraph : function(cmp, temp) { 
          
        var firstValue = [];
        var year = [];
        var meta;
        var months = [ "Jan", "Feb", "Mar", "Apr", "May", "June","July", "Aug", "Sept", "Oct", "Nov", "Dec" ];
        var selectedMonthName = [];


        for(var a=0; a< temp.length; a+=1){
           
            firstValue.push(temp[a].refSent); 
            selectedMonthName.push(months[temp[a].mon-1] + ' '+temp[a].year);
            year.push(temp[a].year);
        }    
        
        
        var el = cmp.find('lineChart').getElement();
        var ctx = el.getContext('2d'); 
        ctx.globalCompositeOperation = 'destination-over';
        //LV Fix - Payal ()
        var k=[];
        var newchart=new Chart(ctx, {
            type: 'line',
            data: {
                labels: selectedMonthName,
                datasets: [{
                    label: cmp.get('v.graphLabel'),
                    data: firstValue,
                    backgroundColor: "#EAF4FD",
                    borderColor:"#3296ED",
                    lineTension : 0
                }]
            },
            options : {
                animation:{
                    onComplete: function() {
                        ctx.fillStyle = "#000"; 
                        ctx.font = "12px 'Helvetica Neue', Helvetica, Arial, sans-serif";
                        meta = this.getDatasetMeta(0);
                        for(var j=0;j<this.data.datasets[0].data.length;j+=1){
                            ctx.fillText(this.data.datasets[0].data[j], meta.data[j]._model.x - 8, meta.data[j]._model.y - 10);
                        }
                    },
                    onProgress: function() {
                        ctx.fillStyle = "#000"; 
                        ctx.font = "12px 'Helvetica Neue', Helvetica, Arial, sans-serif";
                        meta = this.getDatasetMeta(0);
                        for(var j=0;j<this.data.datasets[0].data.length;j+=1){
                            ctx.fillText(this.data.datasets[0].data[j], meta.data[j]._model.x - 8, meta.data[j]._model.y - 10);
                        }
                    }
                },
                legend: {
                    position: "top",
                    align: "start",
                    display: false,
                    labels: {
                        fontColor: '#16325c',
                        boxWidth:0,
                        fontSize:16,
                    }
                },
                scales: {
                    xAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'Referral Created Date'
                        }
                    }],
                    yAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'Record Count'
                        }
                    }]
                }
            }
        });  
        k.push(newchart);

    }
})