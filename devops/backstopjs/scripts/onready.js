module.exports = async (page, scenario, vp) => {
    console.log('SCENARIO > ' + scenario.label);  
    
    // Disable animations
    await page.addStyleTag({content: `*, *:before, *:after { 
            -webkit-animation-delay: 0s !important; 
            -webkit-animation-duration: 0s !important; 
            animation-delay: 0s !important; 
            animation-duration: 0s !important; 
        }`
    });
  };