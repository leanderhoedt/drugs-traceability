# drugs-traceability

// Hier alles onze doc in steken?

We hebben uitgezocht om de hash te laten genereren in de lib/logic.js. We hebben in eerste instantie geprobeerd om een library toe te voegen en aan te roepen. Echter is het niet mogelijk om require te gebruiken in de transaction processor. Hashing hoort ook niet echt thuis in de transaction processor, maar eerder in de client. Daar we voor deze opdracht geen client moesten ontwikkelen, hebben we de hashing in de script file gestopt.