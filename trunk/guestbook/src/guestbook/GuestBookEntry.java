package guestbook;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.users.User;

@PersistenceCapable(identityType = IdentityType.APPLICATION)
public class GuestBookEntry {
    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private Long id;

    @Persistent
    private String content;
    
    @Persistent
    private Set<String> fts;

    public GuestBookEntry(String content) {
        this.content = content;
        
        this.fts = new HashSet<String>();
        
        SearchJanitor.updateFTSStuffForGreeting(this);
    }

    public Long getId() {
        return id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

	public void setFts(Set<String> fts) {
		this.fts = fts;
	}

	public Set<String> getFts() {
		return fts;
	}
}
